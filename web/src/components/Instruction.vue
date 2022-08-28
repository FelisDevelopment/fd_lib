<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div class="absolute bottom-5 right-5 grid grid-flow-col divide-x-[1px] divide-base-content rounded-md bg-base-300/90 py-2" v-if="actions.length > 0">
			<div class="flex items-center gap-2 px-4" v-for="item in actions">
				<kbd class="kbd" :class="item.keyClasses">{{ item.key.toUpperCase() }}</kbd>
				<span class="text-base-content" :class="item.labelClasses">{{ item.label }}</span>
			</div>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject } from 'vue'

const emitter: any = inject('emitter')

interface Instruction {
	key: string
	keyClasses?: string[]
	label: string
	labelClasses?: string[]
}

let actions = $ref<Instruction[]>([])

emitter.on('instruction:open', (event: any) => {
	if (Array.isArray(event)) {
		return event.map((item) => {
			actions.push(item)
		})
	}

	actions.push(event)
})

emitter.on('instruction:close', (event: any) => {
	if (Array.isArray(event)) {
		return event.map((item) => {
			actions = actions.filter((action) => {
				if (action.key.toLocaleLowerCase() === item.key.toLocaleLowerCase() && action.label.toLocaleLowerCase() === item.label.toLocaleLowerCase()) return false

				return true
			})
		})
	}

	actions = actions.filter((item) => {
		if (event.key.toLocaleLowerCase() === item.key.toLocaleLowerCase() && event.label.toLocaleLowerCase() === item.label.toLocaleLowerCase()) return false

		return true
	})
})
</script>
