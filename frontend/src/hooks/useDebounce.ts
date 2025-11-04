import { useCallback, useRef } from 'react'

export function useDebouncedCallback<T extends (...args: any[]) => any>(
  callback: T,
  wait = 300
) {
  const timeout = useRef<ReturnType<typeof setTimeout> | undefined>(undefined)

  return useCallback(
    (...args: Parameters<T>) => {
      const later = () => {
        if (timeout.current) {
          clearTimeout(timeout.current)
        }
        callback(...args)
      }

      if (timeout.current) {
        clearTimeout(timeout.current)
      }
      timeout.current = setTimeout(later, wait)
    },
    [callback, wait]
  )
}