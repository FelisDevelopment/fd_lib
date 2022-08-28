<template>
	<div class="divider" :class="classes">{{ label }}</div>
</template>
<script setup lang="ts">
const props = defineProps({
	label: {
		type: String,
		default: '',
	},
	classes: {
		type: Array,
		default: [],
	},
})
</script>
