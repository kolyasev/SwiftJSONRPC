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
        class func bg(_ block: @escaping ()->()) {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: block)
        }

        class func main(_ block: @escaping ()->()) {
            DispatchQueue.main.async(execute: block)
        }
    }

    class sync
    {
        class func bg(_ block: ()->()) {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).sync(execute: block)
        }

        class func main(_ block: ()->())
        {
            if Thread.isMainThread {
                block()
            }
            else {
                DispatchQueue.main.sync(execute: block)
            }
        }
    }

    // after by @stanislavfeldman
    class after {
        class func bg(_ delay: Double, block: @escaping ()->())
        {
            let when = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).asyncAfter(deadline: when, execute: block)
        }

        class func main(_ delay: Double, block: @escaping ()->())
        {
            let when = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: when, execute: block)
        }
    }
}

// ----------------------------------------------------------------------------
