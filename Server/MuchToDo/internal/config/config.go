package config

import (
	"github.com/spf13/viper"
)

// Config stores all configuration of the application.
type Config struct {
	ServerPort         string `mapstructure:"PORT"`
	MongoURI          string `mapstructure:"MONGO_URI"`
	DBName            string `mapstructure:"DB_NAME"`
	JWTSecretKey      string `mapstructure:"JWT_SECRET_KEY"`
	JWTExpirationHours int    `mapstructure:"JWT_EXPIRATION_HOURS"`
	EnableCache       bool   `mapstructure:"ENABLE_CACHE"`
	RedisAddr         string `mapstructure:"REDIS_ADDR"`
	RedisPassword     string `mapstructure:"REDIS_PASSWORD"`
	LogLevel          string `mapstructure:"LOG_LEVEL"`
	LogFormat         string `mapstructure:"LOG_FORMAT"`
}

// LoadConfig reads configuration from file or environment variables.
func LoadConfig(path string) (config Config, err error) {
	viper.AddConfigPath(path)
	viper.SetConfigName(".env")
	viper.SetConfigType("env")

	viper.AutomaticEnv()

	// Bind env variables so viper.Unmarshal can read them properly
	envKeys := []string{
		"PORT",
		"MONGO_URI",
		"DB_NAME",
		"JWT_SECRET_KEY",
		"JWT_EXPIRATION_HOURS",
		"ENABLE_CACHE",
		"REDIS_ADDR",
		"REDIS_PASSWORD",
		"LOG_LEVEL",
		"LOG_FORMAT",
	}

	for _, key := range envKeys {
		if bindErr := viper.BindEnv(key); bindErr != nil {
			return config, bindErr
		}
	}

	// Set default values
	viper.SetDefault("PORT", "8080")
	viper.SetDefault("ENABLE_CACHE", false)
	viper.SetDefault("JWT_EXPIRATION_HOURS", 72)
	viper.SetDefault("LOG_LEVEL", "DEBUG")
	viper.SetDefault("LOG_FORMAT", "json")

	err = viper.ReadInConfig()
	if err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			return
		}
	}

	err = viper.Unmarshal(&config)
	return
}