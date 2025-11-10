//%attributes = {"invisible":true}
/*

find downloaded .gguf files for LM Studio

LM Studio stores downloaded models in ~/.cache/lm-studio/models, 
in subdirectories with the same name of the models (following HuggingFace's account_name/model_name format), 
with the same filename you saw when you chose to download the file.
https://mozilla-ai.github.io/llamafile/quickstart/#lm-studio
*/

var $models : 4D:C1709.Folder
$models:=Folder:C1567(fk home folder:K87:24).folder(".lmstudio/models")
$files:=$models.folders().reduce(Formula:C1597($1.accumulator.combine($1.value.files(fk recursive:K87:7 | fk ignore invisible:K87:22).query("extension == :1"; ".gguf"))); [])

/*

resolve downloaded .gguf files for ollama

When you download a new model with ollama, 
all its metadata will be stored in a manifest file under ~/.ollama/models/manifests/registry.ollama.ai/library/. 
The directory and manifest file name are the model name as returned by ollama list. 
For instance, for llama3:latest the manifest file will be named .ollama/models/manifests/registry.ollama.ai/library/llama3/latest.
The manifest maps each file related to the model (e.g. GGUF weights, license, prompt template, etc) to a sha256 digest. 
The digest corresponding to the element whose mediaType is application/vnd.ollama.image.model is the one referring to the model's GGUF file.
Each sha256 digest is also used as a filename in the ~/.ollama/models/blobs directory (if you look into that directory you'll see only those sha256-* filenames). 
This means you can directly run llamafile by passing the sha256 digest as the model filename. 
https://mozilla-ai.github.io/llamafile/quickstart/#ollama
*/

var $library : 4D:C1709.Folder
$library:=Folder:C1567(fk home folder:K87:24).folder(".ollama/models/manifests/registry.ollama.ai/library")

$manifests:=$library.folders().map(Formula:C1597($1.result:={name: $1.value.fullName; manifestFile: $1.value.files(fk ignore invisible:K87:22).first()}))\
.map(Formula:C1597($1.result:={name: [$1.value.name; $1.value.manifestFile.fullName].join(":"); manifestFile: $1.value.manifestFile}))\
.map(Formula:C1597($1.result:={name: $1.value.name; manifestFile: $1.value.manifestFile; manifest: JSON Parse:C1218($1.value.manifestFile.getText(); Is object:K8:27)}))\
.map(Formula:C1597($1.result:={name: $1.value.name; manifestFile: $1.value.manifestFile; manifest: $1.value.manifest; digest: $1.value.manifest.layers.query("mediaType == :1"; "application/vnd.ollama.image.model").first().digest}))\
.map(Formula:C1597($1.result:={name: $1.value.name; manifestFile: $1.value.manifestFile; manifest: $1.value.manifest; digest: $1.value.digest; blob: $1.value.manifestFile.parent.parent.parent.parent.parent.folder("blobs").file(Replace string:C233($1.value.digest; ":"; "-"; *))}))

