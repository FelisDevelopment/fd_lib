<template>
	<transition-group
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div
			class="duration-250 fixed flex transform flex-col items-start gap-1 transition-all ease-linear"
			:style="[`left: ${app.getRawMinimapPosition.left + app.getRawMinimapPosition.width + 5}px`, `bottom: ${bottom}px`]"
			ref="vehicleIndicator"
			v-if="app.apps.vehicleIndicator && !app.hudForcefullyHidden"
		>
			<div class="flex flex-shrink-0 flex-grow-0 flex-col items-start justify-start gap-2 rounded-md bg-base-300/70 p-1.5 2xl:p-2">
				<div class="flex w-full items-center justify-center gap-3" v-if="isAircraft">
					<span class="uppercase text-base-content">Alt</span>
					<span class="text-base-content">{{ altitude }}</span>
				</div>
				<div class="relative h-16 w-16 2xl:h-24 2xl:w-24">
					<svg class="h-full w-full text-base-content" viewBox="0 0 75 75" fill="none" xmlns="http://www.w3.org/2000/svg">
						<path
							fill-rule="evenodd"
							clip-rule="evenodd"
							d="M4.65205 37.9642C4.65205 28.9312 8.31819 20.7674 14.252 14.8713C20.1481 8.93745 28.3119 5.27131 37.345 5.27131C46.378 5.27131 54.5418 8.93745 60.4757 14.8713C63.1213 17.517 65.3513 20.6918 66.9765 24.1689L70.9072 22.317C69.0552 18.3863 66.5607 14.8335 63.4993 11.8099C56.8095 5.12013 47.5875 0.962646 37.345 0.962646C27.1402 0.962646 17.8804 5.12013 11.1906 11.8099C4.50086 18.4997 0.343384 27.7595 0.343384 37.9642C0.343384 48.1689 4.50086 57.4288 11.1906 64.1186C13.0048 65.9705 15.008 67.5957 17.2001 68.9941L19.5434 65.3658C17.6158 64.1186 15.8394 62.6823 14.252 61.0949C8.31819 55.1611 4.65205 46.9973 4.65205 37.9642Z"
							fill="currentColor"
						/>
					</svg>
					<svg
						viewBox="0 0 75 75"
						fill="none"
						xmlns="http://www.w3.org/2000/svg"
						class="transform-all absolute top-0 left-0 h-full w-full transform text-base-content duration-100 ease-linear"
						:style="rotation"
					>
						<path
							fill-rule="evenodd"
							clip-rule="evenodd"
							d="M22.7937 56.7863L24.6457 58.0713L19.5433 65.4036C19.2032 65.1768 18.9008 64.9879 18.5984 64.7611C18.2961 64.5343 17.9559 64.3075 17.6536 64.0808L22.7937 56.7863Z"
							fill="currentColor"
						/>
					</svg>
					<div class="absolute top-1/2 left-1/2 -translate-y-1/2 -translate-x-1/2 transform text-center text-xs font-semibold 2xl:text-lg">
						<div class="leading-right flex gap-[2px]">
							<span
								:class="{
									'text-base-content/60': speed < 100,
									'text-base-content': speed >= 100,
								}"
								>{{ speed.toString().split('')[speed.toString().length - 3] ?? 0 }}</span
							>
							<span
								:class="{
									'text-base-content/60': speed < 10,
									'text-base-content': speed >= 10,
								}"
								>{{ speed.toString().split('')[speed.toString().length - 2] ?? 0 }}</span
							>
							<span
								:class="{
									'text-base-content/60': speed <= 0,
									'text-base-content': speed > 0,
								}"
								>{{ speed.toString().split('')[speed.toString().length - 1] ?? 0 }}</span
							>
						</div>
						<div class="text-[0.5rem] uppercase leading-none tracking-wide 2xl:text-xs 2xl:tracking-wider">{{ isKmh ? 'KM / H' : 'MP / H' }}</div>
					</div>
					<div
						class="absolute right-1 bottom-1 flex h-4 w-4 items-center justify-center rounded-full border-2 border-base-content text-[0.45rem] font-light text-base-content 2xl:h-5 2xl:w-5 2xl:text-xs"
					>
						{{ gear }}
					</div>
				</div>
			</div>
			<div class="flex w-full gap-1">
				<transition-group
					enter-active-class="duration-300 ease-out"
					enter-from-class="transform opacity-0"
					enter-to-class="opacity-100"
					leave-active-class="duration-200 ease-in"
					leave-from-class="opacity-100"
					leave-to-class="transform opacity-0"
				>
					<div
						class="relative flex h-7 min-w-[1.75rem] flex-shrink-0 items-center justify-center overflow-hidden rounded-md bg-base-300/70 2xl:h-10 2xl:min-w-[2.5rem] 2k:h-12 2k:min-w-[3rem]"
						v-for="indicator in filteredIndicators"
						:key="indicator.uuid"
						v-show="indicator.shown"
					>
						<div class="absolute bottom-0 w-full transform transition-all duration-100 ease-linear" :class="[indicator.bg || 'bg-primary']" :style="[`height: ${indicator.value}%;`]"></div>
						<div class="flex items-center justify-center gap-2 text-sm text-base-content 2xl:text-base">
							<i class="z-10" :class="indicator.icon"></i>
						</div>
					</div>
				</transition-group>
			</div>
		</div>
	</transition-group>
</template>
<script setup lang="ts">
import { inject, computed } from 'vue'

// Import Store
import { useApp } from '../stores/app'

const app = useApp()
const emitter: any = inject('emitter')

function initialData() {
	return {
		rotation: 0,
		gear: 1,
		speed: 0,
		isKmh: false,
		isAircraft: false,
		altitude: 0,
	}
}

let vehicleIndicator: HTMLDivElement = $ref<HTMLDivElement>()
let rpmRotation = $ref<number>(initialData().rotation)
let gear = $ref<number>(initialData().gear)
let speed = $ref<number>(initialData().speed)
let isKmh = $ref<boolean>(initialData().isKmh)
let isAircraft = $ref<boolean>(initialData().isAircraft)
let altitude = $ref<number>(initialData().altitude)

const rotation = computed(() => ({
	transform: `rotate(${rpmRotation}deg)`,
}))

const bottom = computed(() => {
	return window.screen.height - app.getRawMinimapPosition.bottom
})

interface Indicator {
	uuid: string
	icon: string
	value: number
	bg?: string
	position?: number
	shown: boolean
}

interface Indicators {
	[key: string]: Indicator
}

let indicators = $ref<Indicators>({})

const filteredIndicators = computed(() => {
	return Object.fromEntries(
		Object.entries(indicators).sort(([, a], [, b]) => {
			if (!a.position) {
				a.position = Object.keys(indicators).length + 99
			}

			if (!b.position) {
				b.position = Object.keys(indicators).length + 99
			}

			return a.position - b.position
		})
	)
})

emitter.on('vehicleIndicator:indicator:open', async (event: any) => {
	if (event.uuid) {
		const indicator = indicators[event.uuid] as Indicator

		indicator.shown = true
	}
})

emitter.on('vehicleIndicator:indicator:register', async (event: any) => {
	if (event.uuid) {
		//@ts-ignore
		indicators[event.uuid] = event
	}
})

emitter.on('vehicleIndicator:indicator:update', async (event: any) => {
	if (event.uuid) {
		//@ts-ignore
		indicators[event.uuid][event.key] = event.value
	}
})

emitter.on('vehicleIndicator:indicator:delete', async (event: any) => {
	if (event.uuid) {
		//@ts-ignore
		delete indicators[event.uuid]
	}
})

emitter.on('vehicleIndicator:indicator:close', async (event: any) => {
	if (event.uuid) {
		indicators[event.uuid].shown = false
	}
})

emitter.on('vehicleIndicator:open', (event: any) => {
	app.apps.vehicleIndicator = true
})

emitter.on('vehicleIndicator:update', (event: any) => {
	speed = Math.floor(event.speed) ?? 0
	gear = event.gear ?? 1
	isKmh = event.isKmh ?? false
	isAircraft = event.isAircraft ?? false
	altitude = Math.floor(event.altitude) ?? 0

	const multiplier = 210 / 100

	rpmRotation = Math.floor(event.rpm * 100 * multiplier) - 5

	if (rpmRotation <= 5) {
		rpmRotation = 5
	}
})

emitter.on('vehicleIndicator:close', (event: any) => {
	app.apps.vehicleIndicator = false
})
</script>
