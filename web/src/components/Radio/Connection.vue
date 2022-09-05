<template>
	<div class="flex flex-col overflow-hidden h-full">
		<div class="flex items-center w-full h-[12%] bg-primary/50 select-none">
			<div class="flex flex-1 items-baseline gap-1 pl-2">
				<i class="fa-solid fa-signal text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(11px_+_0.390625vh)] leading-none" v-if="radio.current"></i>
				<i class="fa-solid fa-xmark text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(11px_+_0.390625vh)] leading-none" v-if="!radio.current"></i>
				<span class="text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(11px_+_0.390625vh)] font-semibold leading-none" v-if="radio.current">{{ radio.current }}</span>
			</div>
			<div class="w-0.5 h-[70%] bg-secondary/40 rounded-full"></div>
			<div class="flex flex-1 items-baseline justify-end gap-1 pr-2">
				<span class="text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(11px_+_0.390625vh)] font-semibold leading-none">{{ radio.volume }}</span>
				<i class="fa-solid fa-volume-high text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(11px_+_0.390625vh)] leading-none"></i>
			</div>
		</div>
		<div class="flex flex-col flex-1 overflow-auto scl p-1 gap-1 2xl:p-4 2xl:gap-4">
			<div class="flex bg-primary/50 w-full rounded-md p-3 items-center h-1/3">
				<i class="fa-solid fa-caret-left text-[calc(16px_+_0.390625vh)] 2xl:text-[calc(18px_+_0.390625vh)] pr-2 hover:text-primary-content" @click="radio.updateRadio(true)"></i>

				<div class="flex-1">
					<input
						type="number"
						class="flex-1 text-2xl w-full bg-transparent text-center placeholder:text-primary-content/50 font-semibold focus:outline-none text-[calc(12px_+_0.390625vh)] 2xl:text-[calc(20px_+_0.390625vh)]"
						max="999"
						placeholder="1.00"
						v-model="radio.input"
						@keyup.enter="radio.joinRadio()"
					/>
				</div>
				<i class="fa-solid fa-caret-right text-[calc(16px_+_0.390625vh)] 2xl:text-[calc(18px_+_0.390625vh)] pl-2 hover:text-primary-content" @click="radio.updateRadio()"></i>
			</div>
			<div class="flex justify-between flex-1 gap-1 2xl:gap-4 select-none">
				<div
					class="flex items-center justify-center bg-primary/50 rounded-md hover:bg-primary hover:text-primary-content"
					@click="radio.updateVolume()"
					:class="{
						'w-1/4': radio.isRadioWithList,
						'w-1/2': !radio.isRadioWithList,
					}"
				>
					<i class="fa-solid fa-volume-high text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(10px_+_0.390625vh)]"></i>
				</div>
				<div class="flex flex-col flex-1 items-center justify-evenly w-2/4 gap-1 2xl:gap-2" v-show="radio.isRadioWithList">
					<div class="flex items-center justify-center flex-1 bg-primary/50 rounded-md w-full hover:bg-primary hover:text-primary-content" @click="radio.setTab('change')">
						<i class="fa-solid fa-pen-to-square"></i>
					</div>
					<div class="flex items-center justify-center flex-1 bg-primary/50 rounded-md w-full hover:bg-primary hover:text-primary-content" @click="radio.setTab('list')">
						<i class="fa-solid fa-list-ul"></i>
					</div>
				</div>
				<div
					class="flex items-center justify-center bg-primary/50 rounded-md hover:bg-primary hover:text-primary-content"
					@click="radio.updateVolume(true)"
					:class="{
						'w-1/4': radio.isRadioWithList,
						'w-1/2': !radio.isRadioWithList,
					}"
				>
					<i class="fa-solid fa-volume-low text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(10px_+_0.390625vh)]"></i>
				</div>
			</div>
		</div>
		<div class="flex items-center w-full h-[12%] bg-primary/50 select-none">
			<div class="flex flex-1 items-center justify-center gap-1 pl-2 hover:bg-primary hover:text-primary-content h-full" @click="radio.leaveRadio()">
				<i class="fa-solid fa-power-off text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(10px_+_0.390625vh)]"></i>
				<span class="hidden 2xl:block 2xl:text-[calc(8px_+_0.390625vh)] font-semibold">{{ locale.t('leave_radio') }}</span>
			</div>
			<div class="w-0.5 h-[70%] bg-secondary/40 rounded-full"></div>
			<div class="flex flex-1 items-center justify-center gap-1 pl-2 hover:bg-primary hover:text-primary-content h-full" @click="radio.joinRadio()">
				<i class="fa-solid fa-phone text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(10px_+_0.390625vh)]"></i>
				<span class="hidden 2xl:block 2xl:text-[calc(8px_+_0.390625vh)] font-semibold">{{ locale.t('join_radio') }}</span>
			</div>
		</div>
	</div>
</template>
<script setup lang="ts">
import { watch } from 'vue'

import { useRadio } from '@/stores/radio'
import { useLocale } from '@/stores/locale'

const radio = useRadio()
const locale = useLocale()

watch(
	() => radio.input,
	(value, oldVal) => {
		if (value <= radio.ranges.min) radio.input = radio.ranges.min

		if (value >= radio.ranges.max) radio.input = radio.ranges.max
	}
)
</script>
<style>
input::-webkit-outer-spin-button,
input::-webkit-inner-spin-button {
	-webkit-appearance: none;
	margin: 0;
}
</style>
