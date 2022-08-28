<template>
	<div class="form-control -mb-3 w-full" v-if="label">
		<label class="label w-full">
			<span class="label-text text-base-content" :class="labelClasses" v-html="label"></span>
		</label>
		<span v-if="alt" class="label-text-alt pl-1 text-base-content/50" :class="altClasses" v-html="alt"></span>
	</div>

	<div class="form-control w-full" v-for="radio in selection">
		<label class="label cursor-pointer">
			<span class="label-text" v-html="radio.label"></span>
			<input type="radio" :name="name" class="radio" :value="radio.value" :checked="modelValue === radio.value" :class="inputClasses" @input="updateValue" />
		</label>
	</div>
</template>
<script setup lang="ts">
import type { PropType } from 'vue'

interface Radio {
	label: string
	value: string | number
}

const props = defineProps({
	label: {
		type: String,
		default: '',
	},
	name: {
		type: String,
		default: 'radio',
	},
	selection: {
		type: Array as PropType<Array<Radio>>,
		default: [],
	},
	modelValue: {
		type: [String, Number, Boolean],
		default: null,
	},
	inputClasses: {
		type: Array,
		default: [],
	},
	labelClasses: {
		type: Array,
		default: [],
	},
	alt: {
		type: String,
		default: '',
	},
	altClasses: {
		type: Array,
		default: [],
	},
})

const emit = defineEmits(['update:modelValue'])

const updateValue = (event: any) => {
	emit('update:modelValue', event.target.value)
}
</script>
