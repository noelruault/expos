package main

type ContentMix []ContentConfig

type ContentConfig struct {
	Type     Provider
	Fallback *Provider
}

var (
	config1 = ContentConfig{
		Type:     Provider1,
		Fallback: &Provider2,
	}
	config2 = ContentConfig{
		Type:     Provider2,
		Fallback: &Provider3,
	}
	config3 = ContentConfig{
		Type:     Provider3,
		Fallback: &Provider1,
	}
	config4 = ContentConfig{
		Type:     Provider1,
		Fallback: nil,
	}

	// DefaultConfig represents the repeating sequence of providers to use
	DefaultConfig = []ContentConfig{

		// ?count=12&offset=0'
		// 1 1 2 3 1 1 1 2 1 1 2 3 1
		// ?count=12&offset=10'
		// 2 3 1 1 1 2 1 1 2 3 1 1 1 2
		// ?count=3&offset=10'
		// 2 3 1

		// 1/2     1/2      2/3      3/1     1/nil     1/2      1/2       2/3
		config1, config1, config2, config3, config4, config1, config1, config2,
	}
)
