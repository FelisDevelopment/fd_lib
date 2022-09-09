<template>
	<div class="w-full h-full">
		<div class="flex items-start justify-between w-full h-full py-[10%]">
			<Inventory type="player" />
			<Actions />
			<Inventory type="aaa" />
		</div>
	</div>
</template>
<script setup lang="ts">
import { computed, onMounted } from 'vue'

// components
import Inventory from './Inventory/Inventory.vue'
import Actions from './Inventory/components/Actions.vue'

// testing shit
import { useInventory } from '@/stores/inventory'

const inv = useInventory()

setTimeout(() => {
	inv.populate('player', {
		label: 'Idk',
		slots: 43,
		maxWeight: 2000,
		items: [
			{
				slot: 1,
				type: 'item',
				name: 'id_card',
				info: {
					nationality: 'USA',
					citizenid: 'FRM65129',
					lastname: 'Evli',
					firstname: 'TESTUXAS',
					birthdate: '1999-05-14',
					gender: 1,
				},
				amount: 1,
			},
			{
				slot: 2,
				type: 'item',
				name: 'phone',
				info: [],
				amount: 1,
			},
			{
				slot: 3,
				type: 'item',
				name: 'driver_license',
				info: {
					birthdate: '1999-05-14',
					firstname: 'TESTUXAS',
					type: 'Class C Driver License',
					lastname: 'Evli',
				},
				amount: 1,
			},
		],
	})
}, 2000)
</script>
