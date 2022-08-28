<template>
	<div class="form-control w-full">
		<label class="label">
			<span class="label-text text-base-content" :class="labelClasses">{{ label }}</span>
			<span class="label-text-alt text-base-content/50" v-if="optional">{{ optionalLabel || locale.t('optional') }}</span>
		</label>
		<textarea
			class="textarea textarea-bordered max-h-48 min-h-[4rem] w-full"
			:placeholder="placeholder"
			:value="modelValue"
			@input="updateValue"
			:class="inputClasses"
			:disabled="disabled"
		></textarea>
		<label class="label">
			<span class="label-text-alt text-base-content/50" :class="altClasses" v-if="alt" v-html="alt"></span>
		</label>
	</div>
</template>

<script setup lang="ts">
import { useLocale } from '../../stores/locale'
const locale = useLocale()

const props = defineProps({
	label: {
		type: String,
		default: '',
	},
	alt: {
		type: String,
		default: '',
	},
	optional: {
		type: Boolean,
		default: false,
	},
	optionalLabel: {
		type: String,
		default: 'Optional',
	},
	placeholder: {
		type: String,
		default: '',
	},
	modelValue: {
		type: [String, Number],
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
	altClasses: {
		type: Array,
		default: [],
	},
	disabled: {
		type: Boolean,
		default: false,
	},
})

const emit = defineEmits(['update:modelValue'])

const updateValue = (event: any) => {
	emit('update:modelValue', event.target.value)
}
</script>
