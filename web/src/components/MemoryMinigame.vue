<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div :class="$style.minigame" v-if="apps.memoryMinigame">
			<div :class="$style.splash" ref="splashWrapper">
				<div class="fa" :class="$style.hacker">&#xf21b;</div>
				<span class="block font-bold" ref="splashText">Remote Sequencing Required</span>
			</div>
			<div class="hidden" :class="$style.groups" ref="groupWrapper">
				<component :is="Block" v-for="group in minigame.groups" v-bind="group" @click="handleClick(group.position)" :key="group.position"></component>
			</div>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject, useCssModule } from 'vue'
import { waitFor, range, shuffle } from '../utils'

import { useAxios } from '@vueuse/integrations/useAxios'

import { resource } from '@/utils'

import { useApp } from '@/stores/app'
import { useLocale } from '@/stores/locale'

import Block from './Memory/Block.vue'

const classes = useCssModule()
const emitter: any = inject('emitter')

const locale = useLocale()
const { apps } = useApp()

let groupWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let splashWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let splashText: HTMLSpanElement = $ref<HTMLSpanElement>()

function initialData(): { [key: string]: any } {
	return {
		wrong: 0,
		right: 0,
		clicked: [],
		positions: [],
		goodPositions: [],
		modes: {
			'5': [10, '92px'],
			'6': [14, '74px'],
			'7': [18, '61px'],
			'8': [20, '51px'],
			'9': [24, '44px'],
			'10': [28, '38px'],
		},
		groups: [],
	}
}
let minigame = $ref(initialData())
let data = $ref<{ [key: string]: any }>()

function handleClick(position: number) {
	if (!minigame.gameStarted) return
	if (minigame.clicked.indexOf(position) !== -1) {
		return
	}

	if (minigame.goodPositions.indexOf(position) === -1) {
		minigame.wrong++
		minigame.groups[position].class.push(classes.bad)
		minigame.clicked.push(position)

		check()
		return
	}

	minigame.right++
	minigame.groups[position].class.push(classes.good)
	minigame.clicked.push(position)
	check()
}

async function success() {
	splashText.innerHTML = locale.t('hack_success')

	await waitFor(2000)
	apps.memoryMinigame = false

	useAxios(`https://${resource()}/minigameResult`, {
		method: 'POST',
		data: {
			passed: true,
		},
	})
}

async function failed() {
	splashText.innerHTML = locale.t('hack_failed')

	await waitFor(2000)
	apps.memoryMinigame = false

	useAxios(`https://${resource()}/minigameResult`, {
		method: 'POST',
		data: {
			passed: false,
		},
	})
}

async function check() {
	const tolerance = data.tolerance ?? 3

	if (minigame.wrong >= tolerance) {
		minigame.gameStarted = false

		minigame.goodPositions.forEach((pos: number) => {
			minigame.groups[pos].class.push(classes.proper)
		})

		reset()
		failed()

		return
	}

	if (minigame.right === minigame.goodPositions.length) {
		reset()
		success()
	}
}

async function reset() {
	minigame.gameStarted = false

	clearTimeout(minigame.finishGame)
	splashWrapper.classList.remove('hidden')
	groupWrapper.classList.add('hidden')

	minigame.groups = []
}

async function start() {
	minigame = initialData()

	apps.memoryMinigame = true

	await waitFor(100)
	splashText.innerHTML = locale.t('remote_sequencing_required')

	if (!minigame.modes[data.mode]) {
		data.mode = 7
	}

	let neededPositions = data.positionsNeeded ?? minigame.modes[data.mode][0]

	minigame.positions = range(0, Math.pow(data.mode, 2) - 1)
	minigame.positions = shuffle(minigame.positions)

	if (neededPositions && neededPositions > minigame.positions.length) {
		neededPositions = minigame.modes[data.mode][0]
	}

	minigame.goodPositions = minigame.positions.slice(0, neededPositions)

	for (let i = 0; i < minigame.positions.length; i++) {
		minigame.groups.push({
			class: [classes.group],
			position: i,
			style: {
				width: minigame.modes[data.mode][1],
				height: minigame.modes[data.mode][1],
			},
		})
	}

	await waitFor(2000)
	splashWrapper.classList.add('hidden')
	groupWrapper.classList.remove('hidden')

	minigame.goodPositions.forEach((pos: number) => {
		minigame.groups[pos].class.push(classes.good)
	})

	await waitFor(4000)
	minigame.goodPositions.forEach((pos: number) => {
		const index = minigame.groups[pos].class.indexOf(classes.good)
		if (index !== -1) {
			minigame.groups[pos].class.splice(index, 1)
		}
	})

	minigame.gameStarted = true

	minigame.finishGame = setTimeout(() => {
		minigame.gameStarted = false
		minigame.wrong = data.tolerance ?? 3

		check()
	}, data.duration)
}

emitter.on('memoryMinigame:open', (event: any) => {
	data = event

	start()
})

emitter.on('memoryMinigame:close', (event: any) => {
	apps.memoryMinigame = false
	reset()
})
</script>
<style module>
.minigame {
	@apply m-[0_auto_20px] h-[540px] max-h-[540px] min-h-[540px] w-[540px] min-w-[540px] max-w-[540px] overflow-hidden rounded-md bg-base-300/90;
}
.splash {
	@apply m-[200px_auto] inline-block w-full text-center text-[16px] text-base-content;
}
.splash .hacker {
	@apply mb-[30px] text-[65px];
}
.groups {
	@apply flex select-none flex-wrap justify-evenly;
}
.group {
	@apply box-content h-[74px] w-[74px] border-[8px] border-neutral bg-base-100/90 before:box-content after:box-content;
}
.proper {
	@apply bg-success/60;
}
.good {
	@apply bg-base-content;
}
.bad {
	@apply bg-error/60;
}
</style>
