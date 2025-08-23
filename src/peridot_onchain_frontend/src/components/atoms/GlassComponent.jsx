import React, { forwardRef } from "react";

const GlassComponent = forwardRef(function GlassComponent(
  {
    children,
    className,
  },
) {


  return (
    <div className={`border bg-white/5 backdrop-blur-md border-white/10 ${className}`}>
      {children}
    </div>
  );
});

export default GlassComponent;
