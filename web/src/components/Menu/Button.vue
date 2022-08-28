<template>
	<div class="group relative select-none" v-if="visible">
		<div
			class="flex items-start justify-center gap-3 rounded-md p-3 transition duration-150 ease-linear"
			:class="{
				'bg-base-300/80': index !== currentIndex,
				'text-base-content': index !== currentIndex,
				'bg-primary/80': index === currentIndex,
				'text-primary-content': index === currentIndex,
				'py-5': !description,
				'bg-base-100/90': disabled,
				'hover:bg-primary/80 hover:text-primary-content': !disabled,
			}"
		>
			<div class="w-12" v-if="image">
				<img class="duration-250 transform transition ease-linear group-hover:scale-150" :src="image" alt="icon" />
			</div>
			<div class="flex w-12 items-center justify-center" v-if="icon">
				<i class="" :class="icon"></i>
			</div>
			<div class="flex flex-1 flex-col">
				<span class="text-sm font-semibold" v-html="title"></span>
				<span class="prose-sm text-xs prose-p:mt-1 prose-p:mb-0" v-html="marked.parse(description || '')"></span>
			</div>
			<div class="absolute top-1/2 right-2 -mt-1.5 -translate-y-1/2 transform" v-if="arrow && menu">
				<i class="gg-chevron-right h-2 w-2"></i>
			</div>
		</div>
		<div class="absolute right-full top-0 mr-2 flex w-full flex-1 flex-col rounded-md bg-base-300/90 p-3 text-base-content" v-if="index === currentIndex && metadata">
			<p class="h-full text-center text-lg" v-if="metadata.title" v-html="metadata.title"></p>
			<p class="h-full" v-if="metadata.markdown" v-html="marked.parse(metadata.markdown)"></p>
			<p class="h-full" v-if="metadata.html" v-html="marked.parse(metadata.html)"></p>
			<ul class="list-none" v-else>
				<li v-for="ind in filteredMeta">{{ ind }}: {{ metadata[ind] }}</li>
			</ul>
		</div>
	</div>
</template>
<script setup lang="ts">
import { computed } from 'vue'
import { marked } from 'marked'

const props = withDefaults(
	defineProps<{
		index: number
		currentIndex: number
		title: string
		visible: boolean
		arrow: boolean
		description?: string
		image?: string
		icon?: string
		menu?: any
		disabled?: boolean
		metadata?: {
			[key: string]: any
		}
	}>(),
	{
		index: 0,
		currentIndex: 0,
		title: '',
		visible: false,
		arrow: true,
	}
)
const style = 'text-3xl'

const filteredMeta = computed(() => {
	return props.metadata ? Object.keys(props?.metadata).filter((key) => key !== 'title') : []
})
</script>
