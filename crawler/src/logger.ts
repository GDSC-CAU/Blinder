/* eslint-disable no-console */
import chalk from "chalk"

class Logger {
    static #instance: Logger | null = null

    #dividerString =
        "\n                                                                                                     \n"
    constructor() {
        if (Logger.#instance === null) {
            Logger.#instance = this
        }
    }

    log(message: string) {
        console.log(message)
        return this
    }

    /**
     * @log bold message
     * @param {string | number} message
     */
    bold(message: string) {
        this.log(chalk.bold(message))
        return this
    }
    /**
     * @log clear all logs
     */
    clear() {
        console.clear()
        return this
    }
    /**
     * @log divider `----`
     */
    divider() {
        this.log(`${chalk.bgWhite(this.#dividerString)}`)
        return this
    }
    /**
     * @log header message
     * @param {string} message
     * @param {"success" | "error"} [type="success"]
     */
    header(message: string, type = "success") {
        if (type === "success") {
            this.log(`${chalk.bgGreenBright.black.bold(` ${message} `)}`)
        } else {
            this.log(`${chalk.bgRedBright.black.bold(` ${message} `)}`)
        }
        return this
    }
    getLogger() {
        return Logger.#instance ?? this
    }
}

const logger = new Logger().getLogger()

export { logger }
