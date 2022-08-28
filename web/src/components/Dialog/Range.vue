<template>
	<div class="form-control w-full">
		<label class="label">
			<span class="label-text text-base-content" :class="labelClasses">{{ label }}</span>
		</label>
		<span v-if="alt" class="label-text-alt mb-1 pl-1 text-base-content/50" :class="altClasses" v-html="alt"></span>
		<input type="range" :min="min" :max="max" :value="modelValue" class="range" :step="step" :class="inputClasses" @input="updateValue" />
		<div class="mt-2 flex w-full justify-between px-2 text-xs" v-if="indicators && step > 0">
			<span v-for="index in max / step">|</span>
		</div>
	</div>
</template>
<script setup lang="ts">
const props = defineProps({
	label: {
		type: String,
		default: '',
	},
	modelValue: {
		type: [Number, String],
		default: null,
	},
	min: {
		type: Number,
		default: 0,
	},
	max: {
		type: Number,
		default: 100,
	},
	step: {
		type: Number,
		optional: true,
		default: null,
	},
	indicators: {
		type: Boolean,
		default: false,
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
