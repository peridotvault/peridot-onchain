const StarBorder = ({
    as: Component = "button",
    className = "",
    color = "white",
    speed = "6s",
    thickness = 1,
    children,
    ...rest
}) => {
    return (
        <Component
            className={`relative inline-block overflow-hidden border border-accent_secondary/50 rounded-xl ${className}`}
            style={{
                padding: `${thickness}px 0`,
                ...rest.style
            }}
            {...rest}
        >
            <div
                className="absolute w-[300%] h-[50%] opacity-70 bottom-[-11px] right-[-250%] rounded-full animate-star-movement-bottom z-0"
                style={{
                    background: `radial-gradient(circle, ${color}, transparent 10%)`,
                    animationDuration: speed,
                }}
            ></div>
            <div
                className="absolute w-[300%] h-[50%] opacity-70 top-[-10px] left-[-250%] rounded-full animate-star-movement-top z-0"
                style={{
                    background: `radial-gradient(circle, ${color}, transparent 10%)`,
                    animationDuration: speed,
                }}
            ></div>
            <div className="relative z-1 bg-background_primary  text-white text-center py-3 px-8 font-bold">
                {children}
            </div>
        </Component>
    );
};

export default StarBorder;