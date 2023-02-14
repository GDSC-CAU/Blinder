import { logger } from "./src/logger.js"

type File = {
    title: string
    unit8IntArray: string[]
}

const file: File = {
    unit8IntArray: ["array"],
    title: "title",
}

logger.header("Hello")
