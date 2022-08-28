<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div class="flex min-w-[18rem] max-w-[30rem] flex-col items-center rounded-md bg-base-300/80 py-3 px-5 lg:min-w-[24rem]" v-if="apps.input">
			<div v-if="data?.header" class="flex justify-center text-center text-base font-semibold text-base-content md:text-lg" v-html="data.header"></div>
			<component v-for="(input, index) in inputs" :is="inputTypes[input.type]" v-bind="input.options ?? []" v-model="input.value"></component>
			<div class="flex w-full items-center justify-end gap-2 pt-5">
				<button class="btn" :class="data?.buttons?.close?.classes" v-html="data?.buttons?.close?.label || locale.t('cancel')" @click.prevent="CloseDialog"></button>
				<button class="btn" :class="data?.buttons?.submit?.classes" v-html="data?.buttons?.submit?.label || locale.t('submit')" @click.prevent="SubmitDialog"></button>
			</div>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject, computed } from 'vue'

// Import interfaces
import type { DialogData, InputTypes } from '..//interfaces/dialog.interface'

// Import Store
import { useApp } from '../stores/app'
import { useLocale } from '../stores/locale'

// Import necessary components
import { useAxios } from '@vueuse/integrations/useAxios'

import Input from './Dialog/Input.vue'
import Sepator from './Dialog/Sepator.vue'
import TextArea from './Dialog/TextArea.vue'
import Checkbox from './Dialog/Checkbox.vue'
import Radio from './Dialog/Radio.vue'
import Select from './Dialog/Select.vue'
import Switch from './Dialog/Switch.vue'
import Range from './Dialog/Range.vue'
import Text from './Dialog/Text.vue'

const emitter: any = inject('emitter')

const { apps } = useApp()
const locale = useLocale()

const resource: string | undefined = inject('resource')

// Define Input Types
const inputTypes = {
	input: Input,
	sepator: Sepator,
	textarea: TextArea,
	checkbox: Checkbox,
	radio: Radio,
	select: Select,
	switch: Switch,
	range: Range,
	text: Text,
} as InputTypes

let data = $ref<DialogData | null>()

const inputs = computed(() => {
	if (!data) {
		return []
	}

	if (!data.inputs.length) {
		return []
	}

	return data.inputs.filter((input) => {
		return inputTypes[input.type]
	})
})

function reset() {
	apps.input = false
	data = null

	//@ts-ignore:next-line
	const { data: result, isFinished } = useAxios(`https://${resource}/enableFocus`, {
		method: 'POST',
		data: {
			isFocused: false,
			cursorToggle: false,
			keepInput: false,
		},
	})
}

function CloseDialog() {
	//@ts-ignore:next-line
	const { data: result, isFinished } = useAxios(`https://${resource}/dialogResult`, {
		method: 'POST',
		data: {
			cancelled: true,
		},
	})

	reset()
}

function SubmitDialog() {
	//@ts-ignore:next-line
	const { data: result, isFinished } = useAxios(`https://${resource}/dialogResult`, {
		method: 'POST',
		data: data?.inputs,
	})

	reset()
}

emitter.on('input:open', (dialog: any) => {
	if (!dialog.inputs || !Array.isArray(dialog.inputs)) return

	data = dialog

	apps.input = true

	//@ts-ignore:next-line
	const { data: result, isFinished } = useAxios(`https://${resource}/enableFocus`, {
		method: 'POST',
		data: {
			isFocused: true,
			cursorToggle: true,
			keepInput: false,
		},
	})
})

emitter.on('input:close', () => {
	reset()
})
</script>
