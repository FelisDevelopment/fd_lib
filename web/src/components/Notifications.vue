<template>
	<transition-group
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div v-if="queues.minimap?.length > 0" class="fixed flex flex-col gap-1" :style="overMinimapPosition">
			<transition-group enter-active-class="slideInLeft" leave-active-class="slideOutLeft">
				<div v-for="notification in reversedQueue('minimap')" class="alert w-full rounded-md shadow-lg bg-base-300/80 px-3 py-2 indicator" :class="notification.classes" :key="notification.id">
					<div class="flex gap-2">
						<i v-if="notification.icon" :class="notification.icon"></i>

						<div class="flex flex-col gap-0.5">
							<span v-if="notification.title" class="font-semibold" v-html="notification.title"></span>
							<span class="text-sm" v-html="notification.description"></span>
						</div>
					</div>
					<span v-if="notification.length && notification.length > 1" class="indicator-item badge badge-primary" v-text="notification.length"></span>
				</div>
			</transition-group>
		</div>
		<div v-if="queues['top-center']?.length > 0" class="absolute flex flex-wrap gap-1 max-w-[50vw] top-2 left-1/2 transform -translate-x-1/2">
			<transition-group enter-active-class="bounceInDown" leave-active-class="slideOutLeft">
				<div
					v-for="notification in queues['top-center']"
					class="alert rounded-md shadow-lg bg-base-300/80 px-3 py-2 indicator flex-grow-0"
					:class="notification.classes"
					:key="notification.id"
				>
					<div class="flex gap-2">
						<i v-if="notification.icon" :class="notification.icon"></i>

						<div class="flex flex-col gap-0.5">
							<span v-if="notification.title" class="font-semibold" v-html="notification.title"></span>
							<span class="text-sm" v-html="notification.description"></span>
						</div>
					</div>
					<span v-if="notification.length && notification.length > 1" class="indicator-item badge badge-primary" v-text="notification.length"></span>
				</div>
			</transition-group>
		</div>
		<div v-if="queues['top-right']?.length > 0" class="absolute flex flex-wrap max-w-[60vw] top-2 right-2 gap-1">
			<transition-group enter-active-class="bounceInDown" leave-active-class="slideOutLeft">
				<div v-for="notification in queues['top-right']" class="alert rounded-md shadow-lg bg-base-300/80 px-3 py-2 indicator flex-grow-0" :class="notification.classes" :key="notification.id">
					<div class="flex gap-2">
						<i v-if="notification.icon" :class="notification.icon"></i>

						<div class="flex flex-col gap-0.5">
							<span v-if="notification.title" class="font-semibold" v-html="notification.title"></span>
							<span class="text-sm" v-html="notification.description"></span>
						</div>
					</div>
					<span v-if="notification.length && notification.length > 1" class="indicator-item badge badge-primary" v-text="notification.length"></span>
				</div>
			</transition-group>
		</div>
		<div v-if="queues['center-right']?.length > 0" class="absolute flex flex-col gap-1 top-1/2 transform -translate-y-1/2 right-2">
			<transition-group enter-active-class="slideInRight" leave-active-class="slideOutRight">
				<div
					v-for="notification in queues['center-right']"
					class="alert rounded-md shadow-lg bg-base-300/80 px-3 py-2 indicator flex-grow-0"
					:class="notification.classes"
					:key="notification.id"
				>
					<div class="flex gap-2">
						<i v-if="notification.icon" :class="notification.icon"></i>

						<div class="flex flex-col gap-0.5">
							<span v-if="notification.title" class="font-semibold" v-html="notification.title"></span>
							<span class="text-sm" v-html="notification.description"></span>
						</div>
					</div>
					<span v-if="notification.length && notification.length > 1" class="indicator-item badge badge-primary" v-text="notification.length"></span>
				</div>
			</transition-group>
		</div>
		<div v-if="queues['bottom-right']?.length > 0" class="absolute flex flex-col gap-1 bottom-2 right-2">
			<transition-group enter-active-class="slideInRight" leave-active-class="slideOutRight">
				<div
					v-for="notification in queues['bottom-right']"
					class="alert rounded-md shadow-lg bg-base-300/80 px-3 py-2 indicator flex-grow-0"
					:class="notification.classes"
					:key="notification.id"
				>
					<div class="flex gap-2">
						<i v-if="notification.icon" :class="notification.icon"></i>

						<div class="flex flex-col gap-0.5">
							<span v-if="notification.title" class="font-semibold" v-html="notification.title"></span>
							<span class="text-sm" v-html="notification.description"></span>
						</div>
					</div>
					<span v-if="notification.length && notification.length > 1" class="indicator-item badge badge-primary" v-text="notification.length"></span>
				</div>
			</transition-group>
		</div>
		<div v-if="queues['bottom-center']?.length > 0" class="absolute flex flex-col gap-1 bottom-2 left-1/2 transform -translate-x-1/2">
			<transition-group enter-active-class="bounceInUp" leave-active-class="slideOutRight">
				<div
					v-for="notification in queues['bottom-center']"
					class="alert rounded-md shadow-lg bg-base-300/80 px-3 py-2 indicator flex-grow-0"
					:class="notification.classes"
					:key="notification.id"
				>
					<div class="flex gap-2">
						<i v-if="notification.icon" :class="notification.icon"></i>

						<div class="flex flex-col gap-0.5">
							<span v-if="notification.title" class="font-semibold" v-html="notification.title"></span>
							<span class="text-sm" v-html="notification.description"></span>
						</div>
					</div>
					<span v-if="notification.length && notification.length > 1" class="indicator-item badge badge-primary" v-text="notification.length"></span>
				</div>
			</transition-group>
		</div>
	</transition-group>
</template>
<script setup lang="ts">
import { inject, computed } from 'vue'

// Import Store
import { useApp } from '../stores/app'

interface Notification {
	title?: string
	icon?: string
	description: string
	duration: number
	timeout?: number
	type?: string
	classes?: string[]
	id?: string | number
	length?: number
}

interface Queues {
	[key: string]: Notification[]
}

const availablePositions = ['minimap', 'top-center', 'top-right', 'center-right', 'bottom-right', 'bottom-center']
const app = useApp()
const emitter: any = inject('emitter')
const queues: Queues = $ref({})
let generatedId: number = $ref(0)

const overMinimapPosition = computed(() => {
	let bottom = window.screen.height - app.getRawMinimapPosition.bottom + 5

	if (app.isMinimapShown) {
		bottom = window.screen.height - app.getRawMinimapPosition.top + 5
	}

	return {
		bottom: `${bottom}px`,
		left: `${app.getRawMinimapPosition.left}px`,
		'min-width': `${app.getRawMinimapPosition.width}px`,
		'max-width': `${app.getRawMinimapPosition.width}px`,
	}
})

const reversedQueue = computed(() => (queue: string) => {
	if (queues[queue]?.length <= 0) {
		return []
	}

	return [...queues[queue]].reverse()
})

emitter.on('notifications:open', (event: any) => {
	if (!availablePositions.includes(event.position)) return

	if (!queues[event.position]) {
		queues[event.position] = []
	}

	if (!event.id) {
		generatedId++
		event.id = generatedId
	}

	const alreadyExists = queues[event.position].findIndex((notification: Notification) => {
		if (notification.title && notification.description) {
			return notification.title === event.title && notification.description === event.description
		}

		if (notification.title && !notification.description) {
			return notification.title === event.title
		}

		if (!notification.title && notification.description) {
			return notification.description === event.description
		}

		return notification.title === event.title || notification.description === event.description
	})

	if (alreadyExists > -1) {
		queues[event.position][alreadyExists].length = (queues[event.position][alreadyExists].length ?? 1) + 1

		clearTimeout(queues[event.position][alreadyExists].timeout)
		queues[event.position][alreadyExists].timeout = setTimeout(() => {
			const index = queues[event.position].findIndex((notification: Notification) => {
				return queues[event.position][alreadyExists].id === notification.id
			})

			if (index > -1) {
				queues[event.position].splice(index, 1)
			}
		}, event.duration ?? 3000)
		return
	}

	const length = queues[event.position].push(event)

	queues[event.position][length - 1].timeout = setTimeout(() => {
		const index = queues[event.position].findIndex((notification: Notification) => {
			return event.id === notification.id
		})

		if (index > -1) {
			queues[event.position].splice(index, 1)
		}
	}, event.duration ?? 3000)
})
</script>
