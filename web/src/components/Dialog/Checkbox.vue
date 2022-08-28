<template>
	<div class="form-control w-full">
		<label class="label cursor-pointer">
			<span class="label-text" :class="labelClasses" v-html="label"></span>
			<input type="checkbox" class="checkbox" :checked="modelValue || false" @change="updateValue" :class="inputClasses" :disabled="disabled" />
		</label>
		<span v-if="alt" class="label-text-alt pl-1 text-base-content/50" :class="altClasses" v-html="alt"></span>
	</div>
</template>
<script setup lang="ts">
const props = defineProps({
	label: {
		type: String,
		default: '',
	},
	modelValue: {
		type: [Boolean],
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
	disabled: {
		type: Boolean,
		default: false,
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
	emit('update:modelValue', event.target.checked)
}
</script>
