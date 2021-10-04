package main

import (
	"fmt"
	"reflect"
	"strconv"
	"testing"
	"time"
)

const (
	// TestRemoteIPAddr could be set as an environment requirement. For now, let's just set it
	// to localhost for every test case.
	TestRemoteIPAddr = "127.0.0.1"
)

type providerMock struct {
	Source Provider
}

func (cp providerMock) GetContent(userIP string, count int) ([]*ContentItem, error) {
	return nil, fmt.Errorf("provider '%s' is not implemented", cp.Source)
}

var testTime = func() time.Time {
	return time.Date(2000, 1, 1, 0, 0, 0, 0, time.UTC)
}

var testRandInt = func() int {
	return 1234
}

func TestApp_getContent(t *testing.T) {
	randInt = testRandInt
	testID := strconv.Itoa(randInt())
	timeNow = testTime
	testDate := testTime()

	type appData struct {
		contentClients map[Provider]Client
		config         ContentMix
	}

	tests := []struct {
		name         string
		appData      appData
		countNumber  int
		offsetNumber int
		want         []ContentItem
	}{
		{
			name: "provider1",
			appData: appData{
				contentClients: map[Provider]Client{
					"1": SampleContentProvider{Source: "1"},
				},
				config: []ContentConfig{{Type: Provider1, Fallback: nil}},
			},
			countNumber:  2,
			offsetNumber: 0,
			want: []ContentItem{
				{Source: "1", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "1", ID: testID, Expiry: testDate, Title: "title"},
			},
		},
		{
			name: "provider2",
			appData: appData{
				contentClients: map[Provider]Client{
					"2": SampleContentProvider{Source: "2"},
				},
				config: []ContentConfig{{Type: Provider2, Fallback: nil}},
			},
			countNumber:  2,
			offsetNumber: 0,
			want: []ContentItem{
				{Source: "2", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "2", ID: testID, Expiry: testDate, Title: "title"},
			},
		},
		{
			name: "provider3",
			appData: appData{
				contentClients: map[Provider]Client{
					"3": SampleContentProvider{Source: "3"},
				},
				config: []ContentConfig{{Type: Provider3, Fallback: nil}},
			},
			countNumber:  2,
			offsetNumber: 0,
			want: []ContentItem{
				{Source: "3", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "3", ID: testID, Expiry: testDate, Title: "title"},
			},
		},
		{
			name: "fallbackProvider1",
			appData: appData{
				contentClients: map[Provider]Client{
					"-9": providerMock{Source: "-9"},
					"1":  SampleContentProvider{Source: "1"},
				},
				config: []ContentConfig{{Type: Provider("-9"), Fallback: &Provider1}},
			},
			countNumber:  2,
			offsetNumber: 0,
			want: []ContentItem{
				{Source: "1", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "1", ID: testID, Expiry: testDate, Title: "title"},
			},
		},
		{
			name: "fallbackProvider2",
			appData: appData{
				contentClients: map[Provider]Client{
					"-9": providerMock{Source: "-9"},
					"2":  SampleContentProvider{Source: "2"},
				},
				config: []ContentConfig{{Type: Provider("-9"), Fallback: &Provider2}},
			},
			countNumber:  2,
			offsetNumber: 0,
			want: []ContentItem{
				{Source: "2", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "2", ID: testID, Expiry: testDate, Title: "title"},
			},
		},
		{
			name: "fallbackProvider3",
			appData: appData{
				contentClients: map[Provider]Client{
					"-9": providerMock{Source: "-9"},
					"3":  SampleContentProvider{Source: "3"},
				},
				config: []ContentConfig{{Type: Provider("-9"), Fallback: &Provider3}},
			},
			countNumber:  2,
			offsetNumber: 0,
			want: []ContentItem{
				{Source: "3", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "3", ID: testID, Expiry: testDate, Title: "title"},
			},
		},
		{
			name: "providerFailsNoFallback",
			appData: appData{
				contentClients: map[Provider]Client{
					"-9": providerMock{Source: "-9"},
				},
				config: []ContentConfig{{Type: Provider("-9"), Fallback: nil}},
			},
			countNumber:  0,
			offsetNumber: 0,
			want:         nil,
		},
		{
			name: "testOffsetResponseOrder",
			appData: appData{
				contentClients: map[Provider]Client{
					"1": SampleContentProvider{Source: "1"},
					"2": SampleContentProvider{Source: "2"},
					"3": SampleContentProvider{Source: "3"},
				},
				config: []ContentConfig{
					{Type: Provider1, Fallback: nil},
					{Type: Provider2, Fallback: nil},
					{Type: Provider3, Fallback: nil},
				},
			},
			countNumber:  3,
			offsetNumber: 1, // intent
			want: []ContentItem{
				{Source: "2", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "3", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "1", ID: testID, Expiry: testDate, Title: "title"},
			},
		},
		{
			name: "testOffsetResponseWhenErrorWhileProcessing",
			appData: appData{
				contentClients: map[Provider]Client{
					"1":  SampleContentProvider{Source: "1"},
					"2":  SampleContentProvider{Source: "2"},
					"3":  SampleContentProvider{Source: "3"},
					"-9": providerMock{Source: "-9"},
				},
				config: []ContentConfig{
					{Type: Provider1, Fallback: nil},
					{Type: Provider2, Fallback: nil},
					{Type: Provider3, Fallback: nil},
					{Type: Provider("-9"), Fallback: &Provider1},
					{Type: Provider2, Fallback: nil},
					{Type: Provider3, Fallback: nil},
				},
			},
			countNumber:  6,
			offsetNumber: 1,
			want: []ContentItem{
				{Source: "2", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "3", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "1", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "2", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "3", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "1", ID: testID, Expiry: testDate, Title: "title"},
			},
		},
		{
			name: "errorWithoutFallbackWhileProcessing",
			appData: appData{
				contentClients: map[Provider]Client{
					"1":  SampleContentProvider{Source: "1"},
					"2":  SampleContentProvider{Source: "2"},
					"3":  SampleContentProvider{Source: "3"},
					"-9": providerMock{Source: "-9"},
				},
				config: []ContentConfig{
					{Type: Provider1, Fallback: nil},
					{Type: Provider2, Fallback: nil}, // will start here.
					{Type: Provider3, Fallback: nil},
					{Type: Provider("-9"), Fallback: nil}, // intent
					{Type: Provider1, Fallback: nil},
				},
			},
			countNumber:  99,
			offsetNumber: 1,
			want: []ContentItem{
				{Source: "2", ID: testID, Expiry: testDate, Title: "title"},
				{Source: "3", ID: testID, Expiry: testDate, Title: "title"},
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			a := App{
				ContentClients: tt.appData.contentClients,
				Config:         tt.appData.config,
			}
			if got := a.getContent(tt.countNumber, tt.offsetNumber, TestRemoteIPAddr); !reflect.DeepEqual(got, tt.want) {
				t.Errorf("App.getContent() = %v, want %v", got, tt.want)
			}
		})
	}
}

var (
	ProviderTest = Provider("test")
)

type providerMockForExternalCalls struct {
	items []*ContentItem
	err   error
}

func (cp providerMockForExternalCalls) GetContent(userIP string, count int) ([]*ContentItem, error) {
	return cp.items, cp.err
}

// TestApp_getContent_ExternalCalls is designed in such a way that it would allow to mock suppliers
// that use external connections/resources
func TestApp_getContent_ExternalCalls(t *testing.T) {
	randInt = testRandInt
	testID := strconv.Itoa(randInt())
	testDate := testTime()

	type appData struct {
		contentClients map[Provider]Client
		config         ContentMix
	}

	tests := []struct {
		name         string
		appData      appData
		countNumber  int
		offsetNumber int
		want         []ContentItem
	}{
		{
			name: "provider1",
			appData: appData{
				contentClients: map[Provider]Client{
					Provider1: providerMockForExternalCalls{items: []*ContentItem{
						{Source: "1", ID: testID, Expiry: testDate, Title: "title1"},
					}},
				},
				config: []ContentConfig{{Type: Provider1, Fallback: nil}},
			},
			countNumber:  2,
			offsetNumber: 0,
			want: []ContentItem{
				{Source: "1", ID: testID, Expiry: testDate, Title: "title1"},
				{Source: "1", ID: testID, Expiry: testDate, Title: "title1"},
			},
		},
		{
			name: "fallbackProvider",
			appData: appData{
				contentClients: map[Provider]Client{
					ProviderTest: providerMockForExternalCalls{
						err: fmt.Errorf("provider not available"),
					},
					Provider1: providerMockForExternalCalls{items: []*ContentItem{
						{Source: "1", ID: testID, Expiry: testDate, Title: "title1"},
					}},
				},
				config: []ContentConfig{
					{Type: ProviderTest, Fallback: &Provider1},
				},
			},
			countNumber:  1,
			offsetNumber: 0,
			want: []ContentItem{
				{Source: "1", ID: testID, Expiry: testDate, Title: "title1"},
			},
		},
		{
			name: "multipleProviders",
			appData: appData{
				contentClients: map[Provider]Client{
					Provider1: providerMockForExternalCalls{items: []*ContentItem{
						{Source: "1", ID: testID, Expiry: testDate, Title: "title1"},
					}},
					Provider2: providerMockForExternalCalls{items: []*ContentItem{
						{Source: "2", ID: testID, Expiry: testDate, Title: "title2"},
					}},
				},
				config: []ContentConfig{
					{Type: Provider1, Fallback: nil},
					{Type: Provider2, Fallback: nil},
				},
			},
			countNumber:  2,
			offsetNumber: 0,
			want: []ContentItem{
				{Source: "1", ID: testID, Expiry: testDate, Title: "title1"},
				{Source: "2", ID: testID, Expiry: testDate, Title: "title2"},
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			a := App{
				ContentClients: tt.appData.contentClients,
				Config:         tt.appData.config,
			}
			if got := a.getContent(tt.countNumber, tt.offsetNumber, TestRemoteIPAddr); !reflect.DeepEqual(got, tt.want) {
				t.Errorf("\nApp.getContent() = %v,\n want %v", got, tt.want)
			}
		})
	}
}
