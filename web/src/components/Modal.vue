<template>
	<TransitionRoot as="template" :show="apps.modal">
		<Dialog as="div" class="relative z-10" @close="CloseModal()">
			<TransitionChild as="template" enter="ease-out duration-300" enter-from="opacity-0" enter-to="opacity-100" leave="ease-in duration-200" leave-from="opacity-100" leave-to="opacity-0">
				<div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity" />
			</TransitionChild>

			<div class="fixed inset-0 z-10 overflow-y-auto">
				<div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
					<TransitionChild
						as="template"
						enter="ease-out duration-300"
						enter-from="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
						enter-to="opacity-100 translate-y-0 sm:scale-100"
						leave="ease-in duration-200"
						leave-from="opacity-100 translate-y-0 sm:scale-100"
						leave-to="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
					>
						<DialogPanel class="relative transform overflow-hidden rounded-md bg-base-300 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg">
							<div class="bg-base-100 px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
								<div class="sm:flex sm:items-start">
									<div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
										<DialogTitle as="h3" class="text-lg font-medium leading-6 text-base-content" v-if="data.header"> {{ data.header }} </DialogTitle>
										<div class="prose-sm text-base-content" v-html="marked.parse(data.content)"></div>
									</div>
								</div>
							</div>
							<div class="flex select-none justify-end gap-2 bg-base-100 py-3 px-6">
								<button v-if="data.cancel" type="button" class="btn" :class="data.settings?.cancelClasses" @click="CloseModal()">
									{{ data.settings?.cancelLabel || locale.t('cancel') }}
								</button>
								<button v-if="data.submit" type="button" autofocus class="btn" :class="data.settings?.submitClasses" @click="SubmitModal()">
									{{ data.settings?.submitLabel || locale.t('submit') }}
								</button>
							</div>
						</DialogPanel>
					</TransitionChild>
				</div>
			</div>
		</Dialog>
	</TransitionRoot>
</template>
<script setup lang="ts">
import { inject } from 'vue'
import { marked } from 'marked'

// Import Store
import { useApp } from '../stores/app'
import { useLocale } from '../stores/locale'

// Import necessary components
import { Dialog, DialogPanel, DialogTitle, TransitionChild, TransitionRoot } from '@headlessui/vue'
import { useAxios } from '@vueuse/integrations/useAxios'

interface Modal {
	content: string
	submit: boolean
	cancel: boolean
	header?: string
	settings?: {
		submitClasses?: string[]
		submitLabel?: string
		cancelClasses?: string[]
		cancelLabel?: string
	}
}

const emitter: any = inject('emitter')
const { apps } = useApp()
const locale = useLocale()

const resource: string | undefined = inject('resource')

function initialData(): Modal {
	return {
		content: '',
		submit: true,
		cancel: true,
	}
}

let data = $ref<Modal>(initialData())

function reset() {
	apps.modal = false

	setTimeout(() => {
		data = initialData()
	}, 500)

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

function CloseModal() {
	//@ts-ignore:next-line
	const { data: result, isFinished } = useAxios(`https://${resource}/modalResult`, {
		method: 'POST',
		data: false,
	})

	reset()
}

function SubmitModal() {
	//@ts-ignore:next-line
	const { data: result, isFinished } = useAxios(`https://${resource}/modalResult`, {
		method: 'POST',
		data: true,
	})

	reset()
}

emitter.on('modal:open', (dialog: any) => {
	data.content = dialog.content || '# No content provided'
	data.header = dialog.header || ''
	data.submit = dialog.submit != null ? dialog.submit : data.submit
	data.submit = dialog.cancel != null ? dialog.cancel : data.cancel

	apps.modal = true

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

emitter.on('modal:close', () => {
	reset()
})
</script>
