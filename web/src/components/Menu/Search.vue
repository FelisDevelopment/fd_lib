<template>
	<div class="group relative select-none">
		<div class="flex h-12 items-start justify-center gap-3 rounded-md bg-base-300/80 text-base-content transition duration-150 ease-linear">
			<input type="text" :placeholder="locale.t('search')" class="input h-full w-full bg-transparent" @input="updateValue" :value="modelValue" />
		</div>
	</div>
</template>
<script setup lang="ts">
import { useLocale } from '../../stores/locale'
const locale = useLocale()

const props = defineProps<{
	modelValue: string | number | undefined
}>()

const emit = defineEmits(['update:modelValue'])

const updateValue = (event: any) => {
	emit('update:modelValue', event.target.value)
}
</script>
