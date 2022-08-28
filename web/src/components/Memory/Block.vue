<template>
	<div :class="class" :data-position="position" :style="style"></div>
</template>
<script setup lang="ts">
const prop = defineProps<{
	style: { [key: string]: string | number }
	class: string | string[]
	position: number
}>()
</script>
