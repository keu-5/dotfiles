package config

import "github.com/spf13/viper"

type Profile struct {
	kill  []string `yaml:"kill"`
	Allow []string `yaml:"allow"`
}

type Config struct {
	Profiles map[string]Profile `yaml:"profiles"`
}

func Load() (*Config, error) {
	viper.SetConfigName("config")
	viper.AddConfigPath(".")

	if err := viper.ReadInConfig(); err != nil {
		return nil, err
	}

	var cfg Config
	if err := viper.Unmarshal(&cfg); err != nil {
		return nil, err
	}

	return &cfg, nil
}
