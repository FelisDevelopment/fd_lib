<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div :class="$style.minigame" v-if="apps.pathMinigame">
			<div :class="$style.splash" class="" ref="splashWrapper">
				<div class="fa" :class="$style.hacker">&#xf6ff;</div>
				<span class="block" ref="text"></span>
			</div>
			<div class="hidden" :class="$style.groups" ref="groupsWrapper">
				<div v-for="group in minigame.groups" :class="group.class" class="fa" :key="group.index" @click="handleClick(group.index, group.value ?? 0)" v-html="group.text"></div>
			</div>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject, useCssModule } from 'vue'
import { waitFor, random, shuffle, range } from '../utils'

import { useAxios } from '@vueuse/integrations/useAxios'

import { useApp } from '@/stores/app'
import { useLocale } from '@/stores/locale'

const classes = useCssModule()
const emitter: any = inject('emitter')

const locale = useLocale()
const { apps } = useApp()

const resource: string | undefined = inject('resource')

function initialData() {
	return {
		gameStarted: false,
		wrong: 0,
		lastPos: 0,
		blinkingPos: null,
		bestRoute: null,
		goodPositions: null,
		groups: [],
		pieces: [
			'&#xf443;', // 1 = Pawn
			'&#xf441;', // 2 = Knight
			'&#xf43a;', // 3 = Bishop
			'&#xf447;', // 4 = Rook
			'&#xf445;', // 5 = Queen
			'&#xf43f;', // 6 = King
		],
	}
}

let splashWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let groupsWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let text: HTMLSpanElement = $ref<HTMLSpanElement>()

let minigame = $ref<{ [key: string]: any }>(initialData())
let data = $ref<{ [key: string]: any }>({
	duration: 120000,
})

function maxVertical(pos: number) {
	return Math.floor((48 - pos) / 7)
}

function maxHorizontal(pos: number) {
	let max = (pos + 1) % 7
	if (max > 0) return 7 - max
	else return 0
}

function generateNextPosition(pos: number) {
	let maxV = maxVertical(pos)
	let maxH = maxHorizontal(pos)
	if (maxV === 0) {
		let new_pos = random(random(1, maxH), maxH)
		return [new_pos, pos + new_pos]
	}
	if (maxH === 0) {
		let new_pos = random(random(1, maxV), maxV)
		return [new_pos, pos + new_pos * 7]
	}
	if (random(1, 1000) % 2 === 0) {
		let new_pos = random(random(1, maxH), maxH)
		return [new_pos, pos + new_pos]
	} else {
		let new_pos = random(random(1, maxV), maxV)
		return [new_pos, pos + new_pos * 7]
	}
}

function generateBestRoute(startPos: number) {
	let route = []
	if (random(1, 1000) % 2 === 0) {
		startPos *= 7
	}
	while (startPos < 48) {
		let new_pos = generateNextPosition(startPos)
		route[startPos] = new_pos[0]
		startPos = new_pos[1]
	}

	return route
}

function handleClick(pos: number, value: number) {
	if (!minigame.gameStarted) return

	if (pos === 0) return

	if (minigame.lastPos === 0) {
		minigame.groups.forEach((group: { [key: string]: any }) => {
			const hasBreathing = group.class.indexOf(classes.breathing)

			if (hasBreathing > -1) {
				group.class.splice(hasBreathing, 1)
			}
		})

		groupsWrapper.classList.add(classes.transparent)

		if (pos === minigame.blinkingPos || pos === minigame.blinkingPos * 7) {
			minigame.lastPos = pos

			minigame.groups[pos].class.push(classes.good)
		} else {
			minigame.wrong++
			minigame.groups[pos].class.push(classes.bad)
		}

		check()

		return
	}

	let posJumps = parseInt(minigame.groups[minigame.lastPos].text, 10)

	if (data.pieces) {
		posJumps = parseInt(minigame.groups[minigame.lastPos].value, 10)
	}

	let maxV = maxVertical(minigame.lastPos)
	let maxH = maxHorizontal(minigame.lastPos)

	if (posJumps <= maxH && pos === minigame.lastPos + posJumps) {
		minigame.lastPos = pos
		minigame.groups[pos].class.push(classes.good)
	} else if (posJumps <= maxV && pos === minigame.lastPos + posJumps * 7) {
		minigame.lastPos = pos
		minigame.groups[pos].class.push(classes.good)
	} else {
		minigame.wrong++
		minigame.groups[pos].class.push(classes.bad)
	}

	check()
}

function check() {
	const tolerance = data.tolerance ?? 3

	if (minigame.wrong >= tolerance) {
		minigame.gameStarted = false

		clearTimeout(minigame.hideTimer)

		groupsWrapper.classList.remove(classes.transparent)

		minigame.goodPosition.push(48)
		minigame.goodPosition.forEach((pos: number) => {
			minigame.groups[pos].class.push(classes.proper)
		})

		failed()

		return
	}

	if (minigame.lastPos === 48) {
		minigame.gameStarted = false

		success()
		return
	}
}

async function success() {
	reset()

	text.innerText = locale.t('system_bypassed')

	await waitFor(2000)
	apps.pathMinigame = false

	useAxios(`https://${resource}/minigameResult`, {
		method: 'POST',
		data: {
			passed: true,
		},
	})
}
async function failed() {
	await waitFor(3000)
	reset()

	text.innerText = locale.t('system_didnt_accept_answer')

	await waitFor(2000)
	apps.pathMinigame = false

	useAxios(`https://${resource}/minigameResult`, {
		method: 'POST',
		data: {
			passed: false,
		},
	})
}

function reset() {
	minigame.gameStarted = false

	clearTimeout(minigame.timeout)
	clearTimeout(minigame.hideTimer)

	splashWrapper.classList.remove('hidden')
	groupsWrapper.classList.add('hidden')
	groupsWrapper.classList.remove('transparent')
}

async function start() {
	apps.pathMinigame = true

	await waitFor(100)
	text.innerText = locale.t('network_access_blocked')

	minigame = initialData()

	minigame.blinkingPos = random(1, 4)
	minigame.bestRoute = generateBestRoute(minigame.blinkingPos)
	minigame.goodPosition = Object.keys(minigame.bestRoute)

	for (let i = 0; i < 49; i++) {
		let group: { [key: string]: any } = {
			index: i,
			class: [classes.group],
		}

		switch (i) {
			case 0:
				group.text = '&#xf796;'
				break
			case 48:
				group.text = '&#xf6ff;'
				break
			case minigame.blinkingPos:
			case minigame.blinkingPos * 7:
				group.class.push(classes.breathing)
				if (data.pieces) {
					group.value = random(1, 5)
					group.text = minigame.pieces[group.value - 1]
				} else {
					group.text = random(1, 4)
				}

				break
			default:
				if (data.pieces) {
					group.value = random(1, 5)
					group.text = minigame.pieces[group.value - 1]
				} else {
					group.text = random(1, 5)
				}
		}

		if (minigame.goodPosition.includes(i.toString())) {
			if (data.pieces) {
				group.value = minigame.bestRoute[i]
				group.text = minigame.pieces[group.value - 1]
			} else {
				group.text = minigame.bestRoute[i]
			}
		}

		minigame.groups.push(group)
	}

	await waitFor(2000)
	splashWrapper.classList.add('hidden')
	groupsWrapper.classList.remove('hidden')

	minigame.gameStarted = true

	if (data.hideAfter) {
		minigame.hideTimer = setTimeout(() => {
			groupsWrapper.classList.add(classes.transparent)
		}, data.hideAfter)
	}

	minigame.timeout = setTimeout(() => {
		minigame.gameStarted = false

		minigame.wrong = data.tolerance ?? 3

		check()
	}, data.duration)
}

emitter.on('pathMinigame:open', (event: any) => {
	data = event

	start()
})

emitter.on('pathMinigame:close', (event: any) => {
	apps.memoryMinigame = false

	reset()
})
</script>
<style module>
.minigame {
	@apply m-[0_auto_28px] h-[540px] max-h-[540px] min-h-[540px] w-[540px] min-w-[540px] max-w-[540px] overflow-hidden rounded-md bg-base-300/90;
}
.splash {
	@apply m-[220px_auto] inline-block w-full text-center text-[16px] text-base-content;
}
.splash .hacker {
	@apply mb-[30px] text-[65px];
}
.groups {
	@apply flex select-none flex-wrap justify-evenly;
}
.group {
	@apply box-content h-[61px] w-[61px] border-[8px] border-base-300/90 bg-[#094e1c] text-center text-[26px] leading-[60px] text-white before:box-content after:box-content;
	font-family: 'Font Awesome 5 Free', sans-serif;
}

.group.breathing {
	/* @apply animate-bounce; */
	@apply animate-[breathing-bg_2s_ease-in-out_infinite];
}
.group:first-child {
	@apply bg-[#6acf66] !text-[#008001];
}
.group:last-child {
	@apply bg-[#6acf66] !text-[#f00f18];
}

@keyframes breathing-bg {
	0%,
	100% {
		@apply bg-[#094e1c];
	}
	50% {
		@apply bg-[#6acf66];
	}
}
.groups.transparent .group {
	@apply text-transparent;
}
.proper {
	border-image: linear-gradient(45deg, #ecc800, #564800) 1;
}
.good {
	@apply bg-success;
}
.bad {
	@apply bg-error;
}
</style>
