import TextPressure from "../components/atoms/TextPressure";


export const Footer = () => {

    return (
        <footer className="flex justify-center  bg-background_secondary">
            <div className="max-w-[1200px] px-8 w-full flex flex-col pt-32 gap-10 ">

                {/* mntap */}
                <div className=" flex gap-10 mb-10">
                    <p className="text-3xl w-1/2 max-md:w-full">Connect with us to create incredible, bold and impactful game that aligns with your values and exceeds standards</p>
                </div>
                <div className=" text-lg">
                    <p>Created by Antigane Inc</p>
                    <p>Indonesian Technology Company</p>
                </div>
                <div className="overflow-hidden ">
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
                </div>
            </div>
        </footer>
    );
}
