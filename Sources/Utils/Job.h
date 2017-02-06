#ifndef __THREAD_H__
#define __THREAD_H__


namespace MediaViewer
{

	//!
	//! Generic job class, using the thread pool to run arbitrary jobs.
	//! Those threads are automatically deleted by the thread pool after they
	//! have finished executing.
	//!
	class Job
		: public QRunnable
	{

	public:

		Job(const std::function< void (void) > & job);

	protected:

		void run(void) final;

	private:

		//! The job function
		std::function< void (void) > m_Job;

	};

} // namespace MediaViewer


#endif // __THREAD_H__
