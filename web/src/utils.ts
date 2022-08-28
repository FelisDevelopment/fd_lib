const getResource = () => {
	try {
		//@ts-ignore:next-line
		return GetParentResourceName()
	} catch (err) {
		return 'test'
	}
}

const waitFor = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms))
const random = (min: number, max: number) => Math.floor(Math.random() * (max - min)) + min

const range = (start: number, end: number, length = end - start + 1) => {
	return Array.from({ length }, (_, i) => start + i)
}

const shuffle = (arr: Array<any>) => {
	for (let i = arr.length - 1; i > 0; i--) {
		const j = Math.floor(Math.random() * (i + 1))
		const temp = arr[i]
		arr[i] = arr[j]
		arr[j] = temp
	}

	return arr
}

const resource = () => {
	try {
		//@ts-ignore:next-line
		return GetParentResourceName()
	} catch (err) {
		return 'test'
	}
}

export { getResource, waitFor, random, range, shuffle, resource }
