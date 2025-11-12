property lmstudio_models : 4D:C1709.Folder
property ollama_library : 4D:C1709.Folder
property nomic_ai_gpt4all : 4D:C1709.Folder
property huggingface_hub : 4D:C1709.Folder

Class constructor
	
	This:C1470.lmstudio_models:=Folder:C1567(fk home folder:K87:24).folder(".lmstudio/models")
	This:C1470.ollama_library:=Folder:C1567(fk home folder:K87:24).folder(".ollama/models/manifests/registry.ollama.ai/library")
	This:C1470.nomic_ai_gpt4all:=Folder:C1567(fk user preferences folder:K87:10).parent.folder("nomic.ai/GPT4All")
	This:C1470.huggingface_hub:=Folder:C1567(fk home folder:K87:24).folder(".cache/huggingface/hub")
	
	
Function list() : Collection
	
	return This:C1470._lmstudio().combine(This:C1470._ollama()).combine(This:C1470._gpt4all()).combine(This:C1470._huggingface())
	
Function _reduce_lmstudio($item : Object)
	
	$item.accumulator.combine($item.value.files(fk recursive:K87:7 | fk ignore invisible:K87:22).query("extension == :1"; ".gguf"))
	
Function _gpt4all() : Collection
	
	return This:C1470.nomic_ai_gpt4all.files().query("extension == :1"; ".gguf").map(This:C1470._map_lmstudio)
	
Function _lmstudio() : Collection
	
	return This:C1470.lmstudio_models.folders().reduce(This:C1470._reduce_lmstudio; []).map(This:C1470._map_lmstudio)
	
Function _map_lmstudio($item : Object)
	
	$item.result:={file: $item.value; name: $item.value.name}
	
Function _map_ollama($item : Object)
	
	var $result : Object
	$result:={\
		name: $item.value.fullName; \
		file: $item.value.files(fk ignore invisible:K87:22).first()\
		}
	
	If ($result.file#Null:C1517)
		$result.name:=[$result.name; $result.file.fullName].join(":")
		$result.manifest:=JSON Parse:C1218($result.file.getText(); Is object:K8:27)
		$result.digest:=$result.manifest.layers.query("mediaType == :1"; "application/vnd.ollama.image.model").first()
		If ($result.digest#Null:C1517)
			$result.digest:=$result.digest.digest
			$result.file:=$result.file.parent.parent.parent.parent.parent.folder("blobs").file(Replace string:C233($result.digest; ":"; "-"; *))
			$item.result:=$result
		End if 
	End if 
	
Function _ollama() : Collection
	
	return This:C1470.ollama_library.folders().map(This:C1470._map_ollama).extract("file"; "file"; "name"; "name")
	
Function _huggingface() : Collection
	
	var $models : Collection
	var $results : Collection
	
	$results:=[]
	
	If (Not:C34(This:C1470.huggingface_hub.exists))
		return $results
	End if 
	$models:=This:C1470.huggingface_hub.folders(fk ignore invisible:K87:22)
	
	For each ($model; $models)
		var $refsFolder : 4D:C1709.Folder
		var $refFiles : Collection
		var $refFile : 4D:C1709.File
		var $commitHash : Text
		var $snapshotFolder : 4D:C1709.Folder
		var $ggufFiles : Collection
		var $refName : Text
		
		$refsFolder:=$model.folder("refs")
		
		If ($refsFolder.exists)
			$refFiles:=$refsFolder.files(fk ignore invisible:K87:22)
			
			For each ($refFile; $refFiles)
				$commitHash:=$refFile.getText()
				$refName:=$refFile.name
				
				If ($commitHash#"")
					$snapshotFolder:=$model.folder("snapshots").folder($commitHash)
					
					If ($snapshotFolder.exists)
						$ggufFiles:=$snapshotFolder.files(fk recursive:K87:7 | fk ignore invisible:K87:22).query("extension == :1"; ".gguf")
						
						For each ($file; $ggufFiles)
							$results.push({file: $file; name: $file.name; ref: $refName})
						End for each 
					End if 
				End if 
			End for each 
		End if 
	End for each 
	
	return $results.map(This:C1470._map_huggingface)
	
Function _map_huggingface($item : Object)
	
	$item.result:={file: $item.value.file; name: $item.value.name+":"+$item.value.ref}