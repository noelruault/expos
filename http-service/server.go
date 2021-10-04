package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"sort"
	"strconv"
	"sync"
)

type HTTPError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (he *HTTPError) Error() string {
	return fmt.Sprintf("error: %d - %s", he.Code, he.Message)
}

// App represents the server's internal state.
// It holds configuration about providers and content
type App struct {
	ContentClients map[Provider]Client
	Config         ContentMix
}

// getQueryParam is a helper function that returns the value of a specific URL query param
// or an error if can't be found
func getQueryParam(req *http.Request, name string) (string, error) {
	paramURL, ok := req.URL.Query()[name]
	if !ok || len(paramURL[0]) < 1 {
		return "", fmt.Errorf("URL param '%s' is required", name)
	}
	return paramURL[0], nil
}

// Respond converts a Go value to JSON and binds its value to a ResponseWriter.
// Returns an error if any: the conversion or the binding goes wrong.
func Respond(w http.ResponseWriter, data interface{}, statusCode int) error {
	res, err := json.Marshal(data)
	if err != nil {
		return err
	}

	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(statusCode)
	if _, err := w.Write(res); err != nil {
		return err
	}

	return nil
}

func (a App) getFallbackContent(target int, remoteIPAddr string) ([]*ContentItem, error) {
	// If a provider fails to deliver content, the configuration might contain a fallback to use instead.
	fallbackProvider := a.Config[target].Fallback
	if fallbackProvider == nil {
		err := fmt.Sprintf("inexistent fallback for client '%s'", a.Config[target].Type)
		return nil, fmt.Errorf(err)
	}

	fallbackClient := a.ContentClients[*fallbackProvider]
	if fallbackClient == nil {
		err := fmt.Sprintf("inexistent client for provider '%s'", *fallbackProvider)
		return nil, fmt.Errorf(err)
	}

	var fallbackContent []*ContentItem
	var err error
	if fallbackContent, err = fallbackClient.GetContent(remoteIPAddr, 1); err != nil {
		err := fmt.Sprintf("provider '%s' connection error", *fallbackProvider)
		return nil, fmt.Errorf(err) // if the configuration calls for [1,1,2,3] and 2 fails, the response should only contain [1,1].
	}

	return fallbackContent, nil
}

func orderResult(errorsIndexed map[int]error, contentItemsIndexed map[int][]*ContentItem) []ContentItem {
	errIndexes := make([]int, len(errorsIndexed))

	i := 0
	for key := range errorsIndexed {
		errIndexes[i] = key
		i++
	}
	sort.Ints(errIndexes)

	keys := make([]int, len(contentItemsIndexed))
	j := 0
	for key := range contentItemsIndexed {
		keys[j] = key
		j++
	}
	sort.Ints(keys)

	var orderedItemsResult []ContentItem
	for _, k := range keys {
		for _, item := range contentItemsIndexed[k] {
			if len(errIndexes) > 0 && k > errIndexes[0] {
				break // don't display anything coming after the error
			}
			orderedItemsResult = append(orderedItemsResult, *item)
		}
	}

	return orderedItemsResult
}

// getContent processes consecutive client calls to get the content of n (countNumber) elements
// given a specific offsetNumber from different providers.
// The implementation considers that one of the providers could fail and will use a fallback instead.
// If both fail or the fallback is non-existent, the composite object is returned up to the time before the failure.
func (a App) getContent(countNumber, offsetNumber int, remoteIPAddr string) []ContentItem {
	index := offsetNumber

	contentItems := make(chan []*ContentItem)
	errChan := make(chan error)

	contentItemsIndexed := make(map[int][]*ContentItem)
	errorsIndexed := make(map[int]error)

	wg := &sync.WaitGroup{}

	for i := 0; i < countNumber; i++ {
		wg.Add(1)

		target := index % len(a.Config)
		provider := a.Config[target].Type
		client := a.ContentClients[provider]

		var items []*ContentItem
		var err error

		go func() {
			items, err = client.GetContent(remoteIPAddr, 1) // if you wanted to go fancier you would
			// identify how many articles need to come from provider and then make that call.
			// Probably, by allowing the client to add another URL param to the request.

			if err != nil {
				errChan <- err
				return
			}

			contentItems <- items
		}()
		index++

		select {
		case <-contentItems:
			contentItemsIndexed[index] = items
			wg.Done()

		case <-errChan:
			fallbackItems, err := a.getFallbackContent(target, remoteIPAddr)
			if err != nil {
				log.Printf("get fallback content failed: %+v", err)
				errorsIndexed[index] = err
			}
			contentItemsIndexed[index] = fallbackItems

			wg.Done()
		}

		wg.Wait()
	}

	return orderResult(errorsIndexed, contentItemsIndexed)
}

// Get handles the request parameters and returns a parsed response
func (a App) Get(w http.ResponseWriter, req *http.Request) error {
	count, err := getQueryParam(req, "count")
	if err != nil {
		return Respond(w, HTTPError{Code: http.StatusBadRequest, Message: err.Error()}, http.StatusBadRequest)
	}

	countNumber, err := strconv.Atoi(count)
	if err != nil {
		return Respond(w, HTTPError{Code: http.StatusBadRequest, Message: err.Error()}, http.StatusBadRequest)
	}

	var offsetNumber int
	offset, err := getQueryParam(req, "offset")
	if err == nil {
		offsetNumber, err = strconv.Atoi(offset)
		if err != nil {
			return Respond(w, HTTPError{Code: http.StatusBadRequest, Message: err.Error()}, http.StatusBadRequest)
		}
	}

	remoteIPAddr := req.RemoteAddr // We could also use req.Header.Get("X-Forwarded-For") to get
	// the address from the client if required.

	cs := a.getContent(countNumber, offsetNumber, remoteIPAddr)
	return Respond(w, cs, http.StatusOK)
}

// ServeHTTP responds to an HTTP request.
func (a App) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	log.Printf("Received %s request with URL %s", req.Method, req.URL.String())

	var err error
	switch req.Method {
	case http.MethodGet:

		switch req.URL.Path {
		case "/":
			err = a.Get(w, req)
		default:
			w.WriteHeader(http.StatusNotImplemented)
		}

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	if err != nil {
		log.Printf("ServeHTTP error: %+v", err.Error())
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
}
