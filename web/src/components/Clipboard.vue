<template></template>
<script setup lang="ts">
import { inject } from 'vue'

// Import necessary components
import { useAxios } from '@vueuse/integrations/useAxios'

const emitter: any = inject('emitter')

const resource: string | undefined = inject('resource')

function handleCopy(succ: boolean) {
	useAxios(`https://${resource}/copied`, {
		method: 'POST',
		data: {
			copied: succ,
		},
	})
}

async function copyTextToClipboard(text: string) {
	const textArea = document.createElement('textarea')
	textArea.value = text

	await document.body.appendChild(textArea)
	textArea.select()

	try {
		var successful = document.execCommand('copy')

		if (successful) {
			handleCopy(true)
		} else {
			handleCopy(false)
		}
	} catch (err) {
		handleCopy(false)
	}

	document.body.removeChild(textArea)
}

emitter.on('clipboard:open', (data: any) => {
	copyTextToClipboard(data)
})
</script>
