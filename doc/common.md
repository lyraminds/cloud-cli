# Documentation for Common Shell Script Functions


## `help`

**Description:** Displays help message if the argument is `--help` or `-h`.

**Parameters:**

- `$1`: Argument to check.
- `$2`: Help message.

**Usage:**

```sh
help "$1" "Usage instructions here"
```

---

## `run-sleep`

**Description:** Pauses execution for a specified number of seconds.

**Parameters:**

- `$1`: Number of seconds to sleep.

**Usage:**

```sh
run-sleep 10
```

---

## `empty`

**Description:** Checks if a given argument is empty and prints an error message if it is.

**Parameters:**

- `$1`: Value to check.
- `$2`: Name of the parameter for error message.
- `$3`: Help message to display on error.

**Usage:**

```sh
empty "$1" "Git url" "Usage: run-git <url> <project-name> <branch>"
```

---

