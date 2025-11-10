![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/models)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/models/total)

# models
Find GGUF models on local filesystem

## Usage

```4d
$GGUF:=cs.GGUF.new()
$files:=$GGUF.list()
```

`.gguf` files loaded by the following products are listed:

* LM Studio
* Ollama

```json
[
	{
		"file": "[object File]",
		"name": "tinyllama-1.1b-chat-v1.0.Q8_0"
	},
	{
		"file": "[object File]",
		"name": "nomic-embed-text:latest"
	},
	{
		"file": "[object File]",
		"name": "deepseek-r1:7b"
	},
	{
		"file": "[object File]",
		"name": "mistral:latest"
	}
]
```
