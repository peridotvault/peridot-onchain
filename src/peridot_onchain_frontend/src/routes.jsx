import { createBrowserRouter } from 'react-router-dom';

import { MainLayout } from './layouts/MainLayout';
import { LandingPage } from './pages/landing/_LandingPage';
import { NotFound } from './pages/additional/NotFound';
import { AiPage } from './pages/ai/_AiPage';
import { RoadmapPage } from './pages/roadmap/_RoadmapPage';


const router = createBrowserRouter([
    {
        path: "/",
        element: <MainLayout />,
        children: [
            {
                index: true,
                element: <LandingPage />
            },
            {
                path: "ai",
                element: <AiPage />
            },
            {
                path: "roadmap",
                element: <RoadmapPage />
            },
            {
                path: "*",
                element: <NotFound />
            },
        ]
    },
]);

export default router;