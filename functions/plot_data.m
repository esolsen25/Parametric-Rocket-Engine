function [] = plot_data(engine_contour)
    main_fig = figure(1);
    hold on
    plot(engine_contour(1,:),engine_contour(2,:),'r');
    plot(engine_contour(1,:),-engine_contour(2,:),'r');
    pbaspect([1 1 1])
    grid on
    xlim([-12,6]);ylim([-9,9])
    cd ..\
end