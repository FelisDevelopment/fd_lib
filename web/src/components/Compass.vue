<template>
	<!--
        Original code taken from https://github.com/qbcore-framework/qb-hud/blob/main/html/index.html#L15
        And modified to fit the needs of this project
    -->
	<div class="min-w-screen fixed top-0 left-0 h-[60px] w-screen select-none overflow-hidden font-sans text-[14px] leading-[1.5]" v-show="app.apps.compass && !app.hudForcefullyHidden">
		<div class="relative top-[0.5vh] text-[1.4vh] font-bold capitalize tracking-[0.7px] text-white">
			<div class="absolute left-[55%] m-[0_auto] text-left text-white">{{ street2 }}</div>
			<div class="absolute right-[55%] m-[0_auto] text-right text-white">{{ street1 }}</div>
		</div>
		<div class="relative top-[-0.8vh] m-[0_auto] h-full w-[150px]">
			<div class="absolute inset-x-0 top-[-2%] z-[999] m-[0_auto] text-center text-[2.2vh] font-extralight text-white">˅</div>
			<div class="absolute inset-x-0 top-[80%] m-[0_auto] text-center font-semibold text-white opacity-80">{{ degress }}</div>
			<svg class="relative h-[2vh] w-full font-yan text-[0.35vh] font-bold" viewBox="-90 0 180 5" ref="bezels">
				<rect width="3" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="20" x="-90"></rect>
				<rect width="3" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="9" x="-45"></rect>
				<rect width="4.5" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="20" x="0"></rect>
				<rect width="3" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="9" x="45"></rect>
				<rect width="4.5" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="20" x="90"></rect>
				<rect width="3" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="9" x="135"></rect>
				<rect width="4.5" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="20" x="180"></rect>
				<rect width="3" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="9" x="225"></rect>
				<rect width="4.5" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="20" x="270"></rect>
				<rect width="3" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="9" x="315"></rect>
				<rect width="4.5" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="20" x="360"></rect>
				<rect width="3" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="9" x="405"></rect>
				<rect width="3" stroke="black" fill="white" stroke-width="0.5" stroke-opacity="0.6" height="20" x="450"></rect>
			</svg>
			<svg class="relative top-[-0.5vh] h-[3.5vh] w-full pl-[0.12vw] text-[2.3vh] font-normal tracking-[0.7px]" viewBox="-90 0 180 1.5" ref="bearings">
				<text x="0" y="1.5" dominant-baseline="middle" text-anchor="middle" fill="red" class="font-bold">N</text>
				<text x="360" y="1.5" dominant-baseline="middle" text-anchor="middle" fill="red" class="font-bold">N</text>
				<text x="315" y="-11" dominant-baseline="middle" text-anchor="middle" fill="white" class="text-[1.4vh] font-extrabold">NW</text>
				<text x="-45" y="-11" dominant-baseline="middle" text-anchor="middle" fill="white" class="text-[1.4vh] font-extrabold">NW</text>
				<text x="45" y="-11" dominant-baseline="middle" text-anchor="middle" fill="white" class="text-[1.4vh] font-extrabold">NE</text>
				<text x="405" y="-11" dominant-baseline="middle" text-anchor="middle" fill="white" class="text-[1.4vh] font-extrabold">NE</text>
				<text x="90" y="1.5" dominant-baseline="middle" text-anchor="middle" fill="white">E</text>
				<text x="135" y="-11" dominant-baseline="middle" text-anchor="middle" fill="white" class="text-[1.4vh] font-extrabold">SE</text>
				<text x="180" y="1.5" dominant-baseline="middle" text-anchor="middle" fill="white">S</text>
				<text x="225" y="-11" dominant-baseline="middle" text-anchor="middle" fill="white" class="text-[1.4vh] font-extrabold">SW</text>
				<text x="270" y="1.5" dominant-baseline="middle" text-anchor="middle" fill="white">W</text>
			</svg>
		</div>
	</div>
</template>
<script setup lang="ts">
import { inject } from 'vue'

import { useApp } from '@/stores/app'

const emitter: any = inject('emitter')

const app = useApp()

let bezels: HTMLOrSVGImageElement = $ref<HTMLOrSVGImageElement>()
let bearings: HTMLOrSVGImageElement = $ref<HTMLOrSVGImageElement>()

let degress = $ref<number>(0)
let street1 = $ref<string>('')
let street2 = $ref<string>('')

emitter.on('compass:open', () => {
	app.apps.compass = true
})

emitter.on('compass:update', (event: any) => {
	street1 = event.street1 ?? ''
	street2 = event.street2 ?? ''

	if (event.degress !== undefined) {
		degress = event.degress

		bezels.setAttribute('viewBox', `${event.degress - 90} 0 180 5`)
		bearings.setAttribute('viewBox', `${event.degress - 90} 0 180 1.5`)
	}
})

emitter.on('compass:close', () => {
	app.apps.compass = false
})
</script>
