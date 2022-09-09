<template>
	<div
		draggable
		@dragstart="startDrag($event)"
		@drop="onDrop($event)"
		@dragover.prevent
		@dragenter.prevent
		@mouseover="isHovered = true"
		@mouseleave="isHovered = false"
		class="draggable flex flex-col w-full h-[13.6vh] max-height-[13.6vh] flex-shrink-0 flex-grow-0 rounded actions-inset select-none overflow-hidden"
		:class="{
			'bg-base-100/50': () => !info?.quality || info?.quality > 0,
			'bg-error/20': info?.quality <= 0,
		}"
		ref="itemEl"
	>
		<div class="flex items-center justify-between px-2 pt-1">
			<span class="text-xs font-semibold text-gray-400">{{ weight ? (weight / 1000).toFixed(3) : `0.0` }}</span>
			<span v-if="amount" class="text-xs font-semibold text-gray-400">{{ amount }}x</span>
		</div>
		<div class="flex flex-1 overflow-hidden justify-center">
			<img v-if="img" draggable="false" class="object-contain" :src="img" alt="Item Icon" />
		</div>
		<div
			ref="textEl"
			class="flex-shink-0 whitespace-nowrap text-sm font-semibold text-white px-2 py-1 h-6"
			:class="{ 'item-overflow': isOverflowing, 'flex items-center justify-center': !isOverflowing, truncate: !isHovered && isOverflowing }"
			:style="{
				'--textTransformation': overflow,
			}"
		>
			{{ name }}
		</div>
		<div class="w-full h-1">
			<div class="h-full bg-success"></div>
		</div>
	</div>
</template>
<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useInventory } from '@/stores/inventory'

// This is fucking dumb and I'm too tired to find another workaround, vue fix your shit
// duplicate interface from store
interface Props {
	inv: string
	type: string
	name: string
	slot: number
	amount: number
	info?: { [key: string]: any }
	price?: number
}
const props = defineProps<Props>()
const inv = useInventory()

const textEl: HTMLDivElement = $ref<HTMLDivElement>()
const itemEl: HTMLDivElement = $ref<HTMLDivElement>()

let isHovered = $ref<boolean>(false)

const isOverflowing = computed(() => {
	return textEl?.offsetHeight < textEl?.scrollHeight || textEl?.offsetWidth < textEl?.scrollWidth
})

const overflow = computed(() => {
	return `-${textEl?.scrollWidth}px`
})

const img = computed(() => {
	const itemImg = inv.items[props.name]?.image ?? (props.name ? `acetone.png` : false)
	// const itemImg = inv.items[props.name]?.image

	if (!itemImg) return false

	return new URL(import.meta.env.DEV ? `../../../../images/${itemImg}` : `../${itemImg}`, import.meta.url).href
})

const weight = computed(() => {
	return 0
})

// onMounted(() => {
// 	setTimeout(() => {
// 		console.log(props.name)
// 	}, 3000)
// })

function startDrag(e: any) {
	if (!props.name) {
		e.preventDefault()
		return
	}

	e.dataTransfer.dropEffect = 'move'
	e.dataTransfer.effectAllowed = 'move'
	e.dataTransfer.setData('item', JSON.stringify(props))
	e.dataTransfer.setData('inv', JSON.stringify(props.inv))
}

function onDrop(e: any) {
	const data = JSON.parse(e.dataTransfer.getData('item'))

	console.log(JSON.stringify(data, null, 2))
	if (!props.name) {
		// Move to empty slot
		console.log('move to empty slot')
		// inventory.attemptToMoveToEmptySlot(data, item)
		return
	}
	if (props.name === data.name) {
		// Stack items
		console.log('stack items')
		// inventory.attemptToStackItems(data, item)
		return
	}

	if (props.name !== data.name) {
		// Swap items
		console.log('swap items')
		return
	}

	// // inventory.attemptToMove(JSON.parse(data), item)
	// console.log('dropped', item.slot, item.inv)
	// console.log(e)
}
</script>
