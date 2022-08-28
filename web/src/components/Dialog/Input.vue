<template>
	<div class="form-control w-full">
		<label class="label">
			<span class="label-text flex-1 text-base-content" :class="labelClasses">{{ label }}</span>
			<span class="label-text-alt text-base-content/50" v-if="optional">{{ optionalLabel || locale.t('optional') }}</span>
		</label>
		<label class="input-group select-none" :class="inputGroupClasses" v-if="leftLabel || rightLabel">
			<span v-if="leftLabel">{{ leftLabel }}</span>
			<input :type="inputType" :placeholder="placeholder" :value="modelValue" @input="updateValue" class="input input-bordered w-full" :class="inputClasses" :disabled="disabled" />
			<span v-if="rightLabel">{{ rightLabel }}</span>
		</label>
		<input v-else :type="inputType" :value="modelValue" @input="updateValue" placeholder="Type here" class="input input-bordered w-full" :class="inputClasses" :disabled="disabled" />
		<label class="label">
			<span class="label-text-alt flex-1 text-base-content/50" v-if="alt" v-html="alt" :class="altClasses"></span>
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
	leftLabel: {
		type: [String, Number],
		default: null,
	},
	rightLabel: {
		type: [String, Number],
		default: null,
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
		default: '',
	},
	placeholder: {
		type: String,
		default: '',
	},
	modelValue: {
		type: [String, Number, Boolean],
		default: null,
	},
	inputType: {
		type: String,
		default: 'text',
	},
	inputGroupClasses: {
		type: Array,
		default: [],
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
