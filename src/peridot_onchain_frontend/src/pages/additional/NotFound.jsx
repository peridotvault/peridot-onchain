import React from 'react'

export const NotFound = () => {
  return (
    <div className='w-full flex h-[100%] items-center justify-center  mt-24 py-72 flex-col gap-8'>
      <h1 className='text-5xl'>Page not Found</h1>
      <div className="items-center flex flex-col">
        <p className='text-xl'>This page can’t be found.</p>
        <p className='text-xl'>Double check the URL or head back <a href="/" className='text-accent_primary underline'>Home</a> </p>
      </div>
    </div>
  )
}
