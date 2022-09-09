<template>
	<section class="flex items-center w-2/12 p-10 h-full">
		<div class="flex w-full p-3 item-center flex-col justify-center bg-slate-800 z-10 rounded-md bg-opacity-[.8] gap-3 text-white/50 text-[14px]">
			<input
				v-model="store.amount"
				@wheel.prevent="store.handleWheel($event.deltaY)"
				class="p-2 text-white placeholder:text-[14px] placeholder:text-white/20 bg-slate-900 bg-opacity-50 border-0 focus:select-none rounded-lg text-center actions-inset uppercase"
				tabindex="-1"
				type="number"
				max="9999"
				min="0"
				placeholder="Amount"
			/>
			<button
				@drop="onDrop($event)"
				@dragover.prevent
				@dragenter.prevent
				class="p-2 bg-slate-900 bg-opacity-50 border-0 focus:select-none rounded-lg actions-inset hover:bg-slate-800 hover:bg-opacity-50 hover:text-white/[75] uppercase"
			>
				Use
			</button>
			<button class="p-2 bg-slate-900 bg-opacity-50 border-0 focus:select-none rounded-lg actions-inset hover:bg-slate-800 hover:bg-opacity-50 hover:text-white/[75] uppercase">
				Give Money
			</button>
			<button class="p-2 bg-slate-900 bg-opacity-50 border-0 focus:select-none rounded-lg actions-inset hover:bg-slate-800 hover:bg-opacity-50 hover:text-white/[75] uppercase">Close</button>
		</div>
	</section>
</template>

<script setup lang="ts">
import { useAmount } from '@/stores/inventory'

const store = useAmount()

store.$subscribe((mutation, state) => {
	if (typeof state.amount !== 'number') {
		state.amount = 0
	}

	if (!state.amount) {
		state.amount = 0
	}

	if (state.amount > 9999) {
		state.amount = 9999
	}
})

function onDrop(e: any) {
	console.log('use action')
}
</script>
