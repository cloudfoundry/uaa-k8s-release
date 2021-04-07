package matchers

import (
	"io/ioutil"
	"log"

	"gopkg.in/yaml.v2"
)

type version struct {
	Version string `yaml:version`
}

func LoadVersionFromValues() string {
	content, err := ioutil.ReadFile("../config/values/version.yml")

	if err != nil {
		log.Fatal(err)
	}

	v := version{}
	err = yaml.Unmarshal(content, &v)
	if err != nil {
		log.Fatalln(err)
	}

	return v.Version

}
