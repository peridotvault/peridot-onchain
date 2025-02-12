

export const Footer = () => {

    return (
        <footer className="flex flex-col justify-center items-center pt-32 px-10 gap-10 bg-background_secondary">
            {/* mntap */}
            <div className="container flex gap-10 mb-10">
                <p className="text-3xl w-[500px]">Connect with us to create incredible, bold and impactful game that aligns with your values and exceeds standards</p>
            </div>
            <div className="container text-lg">
                <p>Created by Antigane Inc</p>
                <p>Indonesian Technology Company</p>
            </div>
            <div className="overflow-hidden container h-14 sm:h-24 md:h-28 lg:h-36 xl:h-44 2xl:h-52 text-[5rem] sm:text-[10rem] md:text-[12rem] lg:text-[16rem] xl:text-[20rem] 2xl:text-[24rem] font-black">
                <div className="-translate-y-6 sm:-translate-y-14 md:-translate-y-16 lg:-translate-y-24 xl:-translate-y-32 2xl:-translate-y-40 flex justify-between ">
                    <p >P</p>
                    <p >E</p>
                    <p >R</p>
                    <p >I</p>
                    <p >D</p>
                    <p >O</p>
                    <p >T</p>
                </div>
            </div>
        </footer>
    );
}
