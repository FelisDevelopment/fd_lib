<template>
	<div class="form-control w-full" v-if="label">
		<Listbox v-model="selected" @update:model-value="updateValue">
			<div class="relative w-full">
				<ListboxLabel class="label w-full flex-col items-start" v-if="label">
					<span class="label-text text-base-content" v-html="label"></span>
					<span v-if="alt" class="label-text-alt text-base-content/50" :class="altClasses" v-html="alt"></span>
				</ListboxLabel>
				<ListboxButton class="input relative w-full text-left">
					<span class="block truncate">{{ selected.label }}</span>
					<span class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
						<SelectorIcon class="h-5 w-5 text-base-content" aria-hidden="true" />
					</span>
				</ListboxButton>

				<transition leave-active-class="transition duration-100 ease-in" leave-from-class="opacity-100" leave-to-class="opacity-0">
					<ListboxOptions
						class="absolute z-50 mt-1 max-h-60 w-full overflow-auto rounded-md bg-base-100 py-1 text-base shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm"
					>
						<ListboxOption v-slot="{ active, selected }" v-for="select in selection" :key="select.label" :value="select" as="template">
							<li :class="[active ? 'bg-neutral text-neutral-content' : 'text-base-content', 'relative cursor-default select-none py-2 pl-10 pr-4']">
								<span :class="[selected ? 'font-medium' : 'font-normal', 'block truncate']">{{ select.label }}</span>
								<span v-if="selected" class="absolute inset-y-0 left-0 flex items-center pl-3 text-secondary">
									<CheckIcon class="h-5 w-5" aria-hidden="true" />
								</span>
							</li>
						</ListboxOption>
					</ListboxOptions>
				</transition>
			</div>
		</Listbox>
	</div>
</template>

<script setup lang="ts">
import { Listbox, ListboxLabel, ListboxButton, ListboxOptions, ListboxOption } from '@headlessui/vue'
import { CheckIcon, SelectorIcon } from '@heroicons/vue/solid'
import { onMounted, type PropType } from 'vue'

interface SelectOption {
	label: string
	value: string | number | boolean
}

const props = defineProps({
	label: {
		type: String,
		default: '',
	},
	selection: {
		type: Array as PropType<SelectOption[]>,
		default: [],
	},
	modelValue: {
		type: [String, Number, Boolean, Object],
		default: null,
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

const selected = $ref<SelectOption>(props.selection.find((select) => select.value === props.modelValue) ?? (props.selection[0] as SelectOption))

const emit = defineEmits(['update:modelValue'])

const updateValue = (event: any) => {
	emit('update:modelValue', event)
}

onMounted(() => {
	emit('update:modelValue', selected)
})
</script>
