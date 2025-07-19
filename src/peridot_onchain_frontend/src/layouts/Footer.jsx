import TextPressure from "../components/atoms/TextPressure";


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
            <div className="overflow-hidden container">
                <div style={{ position: 'relative', height: '200px' }}>
                    <TextPressure
                        text="PeridotVault"
                        flex={true}
                        alpha={false}
                        stroke={false}
                        width={true}
                        weight={true}
                        italic={true}
                        textColor="#ffffff"
                        strokeColor="#ff0000"
                        minFontSize={36}
                    />
                </div>
                {/* <div className="-translate-y-6 sm:-translate-y-14 md:-translate-y-16 lg:-translate-y-24 xl:-translate-y-32 2xl:-translate-y-40 flex justify-between ">
                    <p >P</p>
                    <p >E</p>
                    <p >R</p>
                    <p >I</p>
                    <p >D</p>
                    <p >O</p>
                    <p >T</p>
                </div> */}
            </div>
        </footer>
    );
}
