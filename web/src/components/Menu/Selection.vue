<template>
	<div class="group relative select-none" v-if="visible">
		<div
			class="flex items-start justify-center gap-3 rounded-md p-3 transition duration-150 ease-linear"
			:class="{
				'bg-base-300/80': index !== currentIndex,
				'text-base-content': index !== currentIndex,
				'bg-primary/80': index === currentIndex,
				'text-primary-content': index === currentIndex,
			}"
		>
			<div class="flex flex-1 flex-col">
				<span class="text-sm font-semibold" v-html="title"></span>
				<ul :class="$style.selection">
					<li v-for="(item, ind) in values" :class="[selected === ind ? $style.active : '']">
						{{ item.label || item }}
					</li>
				</ul>
			</div>
		</div>
	</div>
</template>
<script setup lang="ts">
const props = withDefaults(
	defineProps<{
		index: number
		selected: number
		currentIndex: number
		title: string
		values: any[]
		visible: boolean
	}>(),
	{
		index: 0,
		selected: 0,
		currentIndex: 0,
		title: '',
		visible: false,
	}
)
</script>
<style module>
.selection {
	position: relative;
	@apply h-full;
}

.selection li {
	display: none;
	white-space: nowrap;
}

.selection > .active {
	@apply flex items-center justify-center;
}

.selection > .active:before {
	@apply absolute top-1/2 left-0.5 h-[14px] w-[10px] -translate-y-1/2 transform bg-[url('@/assets/menu-arrow.png')] bg-no-repeat content-[''];
	background-position: 0 0;
}

.selection > .active:after {
	@apply absolute top-1/2 right-0.5 h-[14px] w-[10px] -translate-y-1/2 transform bg-[url('@/assets/menu-arrow.png')] bg-no-repeat content-[''];
	background-position: -30px 0;
}

ul .active div span .selection .active:before {
	background-position: -10px 0;
}

ul .active div span .selection .active:after {
	background-position: -20px 0;
}
</style>
