import { useCallback, useRef } from 'react'

export function useDebouncedCallback<T extends (...args: any[]) => any>(
  callback: T,
  wait = 300
) {
  const timeout = useRef<ReturnType<typeof setTimeout>>()

  return useCallback(
    (...args: Parameters<T>) => {
      const later = () => {
        clearTimeout(timeout.current)
        callback(...args)
      }

      clearTimeout(timeout.current)
      timeout.current = setTimeout(later, wait)
    },
    [callback, wait]
  )
}