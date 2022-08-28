<template>
	<div class="prose-sm text-base-content" v-html="marked.parse(text)"></div>
</template>

<script setup lang="ts">
import { marked } from 'marked'

const props = defineProps({
	text: {
		type: String,
		default: '',
	},
})
</script>
