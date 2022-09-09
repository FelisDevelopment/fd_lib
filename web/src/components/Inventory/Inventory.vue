<template>
	<div class="flex flex-col w-5/12 max-h-[65vh] p-2.5 bg-base-300/80 rounded gap-1.5">
		<Bar />
		<div class="overflow-y-auto grid gap-0.5 grid-cols-5 scl">
			<InvItem v-for="[index, item] in inventory.items?.entries() ?? []" :key="`${type}-${item.slot}`" :inv="type" v-bind="item" />
		</div>
	</div>
</template>
<script setup lang="ts">
import Bar from './components/Bar.vue'
import InvItem from './Items/Item.vue'

import { useInventory, type Inventory } from '@/stores/inventory'

const invState = useInventory()

const props = defineProps<{
	type: string
}>()

const inventory = $ref<Inventory>(props.type === 'player' ? invState.getPlayerInventory : invState.getSecondaryInventory)
</script>
