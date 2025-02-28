.PHONY: image run
image:
	pnpm run build
	podman build -t ocr-service-front -f Containerfile

run:
	podman run --rm -it -p 3000:3000 ocr-service-front

push:
	podman tag ocr-service-front gtlabcontainerregistry.azurecr.io/ocr-service-front
	podman push gtlabcontainerregistry.azurecr.io/ocr-service-front
