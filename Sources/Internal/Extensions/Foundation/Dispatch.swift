// ----------------------------------------------------------------------------
// GCD wrapper in Swift
// @link https://gist.github.com/Inferis/0813bf742742774d55fa
// ----------------------------------------------------------------------------

import Foundation

// ----------------------------------------------------------------------------

class dispatch
{
    class async
    {
        class func bg(block: dispatch_block_t) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
        }

        class func main(block: dispatch_block_t) {
            dispatch_async(dispatch_get_main_queue(), block)
        }
    }

    class sync
    {
        class func bg(block: dispatch_block_t) {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
        }

        class func main(block: dispatch_block_t)
        {
            if NSThread.isMainThread() {
                block()
            }
            else {
                dispatch_sync(dispatch_get_main_queue(), block)
            }
        }
    }

    // after by @stanislavfeldman
    class after {
        class func bg(delay: Double, block: dispatch_block_t)
        {
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
        }

        class func main(delay: Double, block: dispatch_block_t)
        {
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue(), block)
        }
    }
}

// ----------------------------------------------------------------------------
