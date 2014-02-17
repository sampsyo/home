---
title: "Simple Cluster Computing in Python"
kind: article
layout: post
excerpt: |
    I've written a simple Python library for running massively parallel tasks on compute clusters. [Cluster-Workers][] makes it simple to get up and running with the kinds of parallelism that academics usually need when running large-scale batches of experiments. See if it fits your cluster-y use case as well as it does mine.

    [cluster-workers]: https://github.com/sampsyo/cluster-workers
---

In every fiefdom of computer science I can think of, one eventually needs to run enormous, computationally intensive experiments. For this purpose, departments and research labs typically have at least one compute cluster lying around. To make a deadline, sometimes you have to throw hundreds of cores at a task---but, in every case, this is easier said than done.

I frequently find myself needing to throw together one-off data collection scripts that take advantage of tens to hundreds of CPUs to greatly accelerate the action--result feedback loop. For these tasks, frameworks like [Hadoop][], [Disco][], and [Spark][] are too data-oriented: I typically need to run arbitrary programs, not just analyze a bunch of data. So, likely in a misguided fit of NIH syndrome, I've now written three different systems for quickly writing programs that distribute work across a compute cluster.

[Disco]: http://discoproject.org
[Spark]: http://www.spark-project.org
[Hadoop]: http://hadoop.apache.org

The latest iteration is called [Cluster-Workers][]. It's at a point now that it could be useful to other researchers who want to quickly spin up compute power without too much fiddling.

[cluster-workers]: https://github.com/sampsyo/cluster-workers


Setting Up Workers
------------------

The first step to using Cluster-Workers is to set up the cluster nodes that will execute jobs. To do this, install the CW Python package on the cluster by running something like this:

    $ git clone git://github.com/sampsyo/cluster-workers.git
    $ cd cluster-workers
    $ pip install -e .

(I'm assuming the cluster has a shared filesystem here.) Then, you'll need to start one "master" node and many "worker" nodes. To start the master, run:

    python -m cw.master

and on each worker, run:

    python -m cw.worker HOST

where `HOST` is the name of the first machine. If you use [SLURM][], I've provided [a script called slurm.py][slurmscript] that automatically starts processes with the right arguments.

The number of workers determines the parallelism you can leverage to speed up your program. The master is tasked with connecting to the main program, receiving jobs, sending them out to workers, and gathering the results. Once you have the master and workers running, you can leave them in place while you run several programs---possibly concurrently---that use the CW infrastructure.

[SLURM]: https://computing.llnl.gov/linux/slurm/
[slurmscript]: https://github.com/sampsyo/cluster-workers#using-with-slurm


Writing Parallel Programs
-------------------------

A program that uses a CW cluster of machines is a *client* process. To communicate with the master, a client starts a `ClientThread`, sets a callback function, and initiates jobs:

    def my_callback(jobid, result):
        print(jobid, 'completed')
    thread = cw.client.ClientThread(my_callback, host='master.local')
    thread.start()
    jobid = thread.submit(expensive_func, arg)
    print(jobid, 'started')

Each call to `submit` sends a function along with its arguments to the master for execution on a worker. When the job completes, the master notifies the client, which then executes the provided callback function with a job ID that was returned from `submit()`.

When instantiating `ClientThread`, you have to provide the hostname of the master machine if it's not running locally. For SLURM users, however, CW provides the function `cw.slurm_master_host()` to automatically identify this machine.


Next Steps
----------

The token/callback interface provided by `ClientThread` is enough to get work done, but it's not the most elegant way to program asynchronously. There are a few common patterns that big cluster jobs typically need to follow, and I hope to add them to this library to make it even easier to write practical parallel programs:

* Easier association of the call and asynchronous response. It's frustrating to have to store enough data associated with a job ID to continue work when the callback eventually comes. It would be nice to be able to write programs that clearly attach the job submission code to the code that executes after job completion.
* Persistence of results. In many large cluster jobs, it's impractical to store all results in memory while waiting for everything to complete. Moreover, if something goes wrong partway through a huge task, it's very helpful to be able to restart the job without losing too much work. For this reason, the library should provide an easy way to store outputs on disk as they arrive.
* Network usage optimizations. Currently, the library serializes functions and arguments and sends them across the network for each job. This makes it easy to set up a cluster---no need to move code over *a priori* before running a program. However, typical cluster applications run the same functions over and over with slightly different arguments. There should be a way to cache functions on the workers so they don't need to be transmitted every time.

If you're interested in writing quick cluster-scale parallel Python jobs, please [let me know][email] what you're interested in---it would be awesome to make Cluster-Workers useful for everybody.

[email]: mailto:asampson@cs.washington.edu
