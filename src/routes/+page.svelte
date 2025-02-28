<script lang="ts">
    import { FileDropzone } from '@skeletonlabs/skeleton';
    import { RadioGroup, RadioItem } from '@skeletonlabs/skeleton';
    import { ProgressRadial } from '@skeletonlabs/skeleton';
    import { CodeBlock } from '@skeletonlabs/skeleton';
    import { scale } from 'svelte/transition';

    const descriptions = {
        eng: "tesseract default english model", 
        "ub_smi": "a model trained exclusively on manually annotated Sámi data",
        "smi": "the Norwegian base model fine-tuned on manually annotated Sámi data",
        "smi_nor": "the Norwegian base model fine-tuned on manually annotated Sámi and Norwegian data",
        "smi_pred": "the Norwegian base model fine-tuned on manually annotated and automatically transcribed Sámi data",
        "smi_nor_pred": " the Norwegian base model fine-tuned on manually annotated and automatically transcribed Sámi data, and manually annotated Norwegian data",
        "synth_base": " the Norwegian base model fine-tuned on synthetic* Sámi data",
        "sb_smi": " synth_base fine-tuned on manually annotated Sámi data",
        "sb_smi_nor_pred": " synth_base fine-tuned on manually annotated and automatically transcribed Sámi data, and manually annotated Norwegian data",
        "gt_nor_sme": "Best norwegian/sami giellatekno model",
        "gt_sme_friis": "Giellatekno north sámi, friis orthography model",
    };
    let model = $state("eng");
    let model_desc = $derived.by(() => descriptions[model]);
    let results = $state("");
    let waiting = $state(false);

    async function on_fileselect_change(e: Event): void {
        if (e.target === null) { return; }
        if (e.target.files === null) { return; }
        if (e.target.files.length === 0) { return; }

        let file = e.target.files[0];
        let name = file.name;
        let content_type = file.type;

        let url = `https://gtweb-02.uit.no/ocr-api/api/v1/images?language=${model}`;

        let data = new FormData();
        data.append("upload", file);
        data.append("content-type", content_type);
        waiting = true;
        let request = new Request(url, { method: "POST", body: data });
        let response = await fetch(request);
        if (!response.ok) {
            results = "[FAILED]";
            return;
        }
        let json = await response.json();
        waiting = false;
        results = json.text;
    }
</script>

<div class="grid justify-center">
<h2 class="h2">Giellatekno ocr-service</h2>

<div class="card p-4">
    <header class="card-header">
        <p>Remember, you can also use the API directly. Here's an example using <em>curl</em> (and <em>jq</em>):</p>
        <p>Substitute <em>FILENAME</em>, and <em>language=...</em>, and remember to set proper <em>content-type</em></p>
    </header>
    <section class="p-4">
        <CodeBlock language="sh" code={"curl -s -F upload=@FILENAME.png -F content-type=image/png https://gtweb-02.uit.no/ocr-api/api/v1/images?language=smi_nor | jq -r '.text'"}></CodeBlock>
    </section>
</div>

<div class="card">
    <header class="card-header">
    <h3 class="h3">Model:</h3>
    </header>

    <section class="p-4">
        <p>
            Models marked <span class="badge variant-filled bg-primary-500">GT</span> are Giellatekno models.
            Models marked <span class="badge variant-filled bg-secondary-500">NB</span> are models from the Norwegian National Library (Nasjonalbiblioteket).
        </p>
        <p>Read about the NB models here: <a class="text-blue-800" href="https://www.nb.no/sprakbanken/ressurskatalog/oai-nb-no-sbr-100/">nb.no/sprakbanken/ressurskatalog/oai-nb-no-sbr-100/</a></p>
        <div class="flex">
            <RadioGroup required rounded="rounded-container-token" flexDirection="flex-col">
                <RadioItem bind:group={model} name="eng" value={"eng"}>eng</RadioItem>
                <RadioItem bind:group={model} name="gt_nor_sme" value={"gt_nor_sme"}>gt_nor_sme <span class="badge variant-filled bg-primary-500">GT</span></RadioItem>
                <RadioItem bind:group={model} name="gt_sme_friis" value={"gt_sme_friis"}>gt_sme_friis <span class="badge variant-filled bg-primary-500">GT</span></RadioItem>
                <RadioItem bind:group={model} name="sb_smi_nor_pred" value={"sb_smi_nor_pred"}>sb_smi_nor_pred <span class="badge variant-filled bg-secondary-500">NB</span></RadioItem>
                <RadioItem bind:group={model} name="sb_smi" value={"sb_smi"}>sb_smi <span class="badge variant-filled bg-secondary-500">NB</span></RadioItem>
                <RadioItem bind:group={model} name="smi_nor_pred" value={"smi_nor_pred"}>smi_nor_pred <span class="badge variant-filled bg-secondary-500">NB</span></RadioItem>
                <RadioItem bind:group={model} name="smi_nor" value={"smi_nor"}>smi_nor <span class="badge variant-filled bg-secondary-500">NB</span></RadioItem>
                <RadioItem bind:group={model} name="smi_pred" value={"smi_pred"}>smi_pred <span class="badge variant-filled bg-secondary-500">NB</span></RadioItem>
                <RadioItem bind:group={model} name="smi" value={"smi"}>smi <span class="badge variant-filled bg-secondary-500">NB</span></RadioItem>
                <RadioItem bind:group={model} name="synth_base" value={"synth_base"}>synth_base <span class="badge variant-filled bg-secondary-500">NB</span></RadioItem>
                <RadioItem bind:group={model} name="ub_smi" value={"ub_smi"}>ub_smi <span class="badge variant-filled bg-secondary-500">NB</span></RadioItem>
            </RadioGroup>

            <div>
                {model_desc}
            </div>
        </div>
    </section>
</div>

<FileDropzone name="files" on:change={on_fileselect_change}>
	<svelte:fragment slot="lead">(icon)</svelte:fragment>
    <svelte:fragment slot="message"><em>Click to select a file</em> or drag and drop.</svelte:fragment>
	<svelte:fragment slot="meta">PNG, JPG, GIF or WEBP.</svelte:fragment>
</FileDropzone>

<h2>Results:</h2>
{#if waiting}
    <ProgressRadial />
{:else}
    <textarea class="textarea" rows="4">{results}</textarea>
{/if}

</div>

<style>
    main {
        width: max-content;
    }
</style>
